#include <cmath>
#include <string>
#include "wx/wx.h"
#include "wx/defs.h"
#include "wx_bgi_wx.h"
#include "wx_bgi.h"
#include "wx_bgi_ext.h"
#include "wx_bgi_3d.h"
#include "wx_bgi_solid.h"
#include "wx_bgi_dds.h"

using namespace bgi;

class DoughnutCanvas : public wxbgi::WxBgiCanvas
{
public:
    explicit DoughnutCanvas(wxWindow* parent)
        : WxBgiCanvas(parent, wxID_ANY, wxDefaultPosition, wxDefaultSize),
          m_timer(this)
    {
        Bind(wxEVT_TIMER, &DoughnutCanvas::OnTimer, this);
    }

protected:
    void PreBlit(int w, int h) override
    {
        if (!m_ready) {
            m_ready = true;
            m_viewWidth = w;
            m_viewHeight = h;
            setupCamera(w, h);
            buildScene();
            m_timer.Start(30);
        }
        else if (w != m_viewWidth || h != m_viewHeight) {
            m_viewWidth = w;
            m_viewHeight = h;
            wxbgi_cam_set_screen_viewport("doughnut_cam", 0, 0, w, h);
        }

        renderFrame(w, h);
    }

private:
    void OnTimer(wxTimerEvent& WXUNUSED(evt))
    {
        m_phase += 3.5f;
        if (m_phase >= 360.0f) {
            m_phase -= 360.0f;
        }
        Refresh(false);
    }

    void setupCamera(int w, int h)
    {
        wxbgi_cam_create("doughnut_cam", WXBGI_CAM_PERSPECTIVE);
        wxbgi_cam_set_perspective("doughnut_cam", 48.0f, 0.1f, 100.0f);
        wxbgi_cam_set_up("doughnut_cam", 0.0f, 0.0f, 1.0f);
        wxbgi_cam_set_screen_viewport("doughnut_cam", 0, 0, w, h);
        wxbgi_cam_set_active("doughnut_cam");
        applyOrbit();
    }

    void buildScene()
    {
        wxbgi_dds_clear();
        cleardevice();

        wxbgi_solid_set_draw_mode(WXBGI_SOLID_SMOOTH);
        wxbgi_solid_set_edge_color(WHITE);
        wxbgi_solid_set_face_color(CYAN);
        wxbgi_solid_set_light_dir(-0.4f, 0.5f, 0.7f);
        wxbgi_solid_set_fill_light(0.15f, -0.25f, -0.45f, 0.35f);
        wxbgi_solid_set_ambient(0.22f);
        wxbgi_solid_set_diffuse(0.70f);
        wxbgi_solid_set_specular(0.45f, 56.0f);

        setcolor(DARKGRAY);
        for (int i = -4; i <= 4; ++i) {
            wxbgi_world_line((float)i, -4.0f, 0.0f, (float)i, 4.0f, 0.0f);
            wxbgi_world_line(-4.0f, (float)i, 0.0f, 4.0f, (float)i, 0.0f);
        }

        wxbgi_solid_set_face_color(YELLOW);
        wxbgi_solid_torus(0.0f, 0.0f, 0.0f, 2.0f, 0.5f, 64, 32);
    }

    void applyOrbit()
    {
        const float radians = m_phase * static_cast<float>(M_PI) / 180.0f;
        const float radius = 8.0f;
        const float eyeX = radius * std::cos(radians);
        const float eyeY = radius * std::sin(radians);
        const float eyeZ = 2.2f;

        wxbgi_cam_set_eye("doughnut_cam", eyeX, eyeY, eyeZ);
        wxbgi_cam_set_target("doughnut_cam", 0.0f, 0.0f, 0.0f);
        wxbgi_cam_set_active("doughnut_cam");
    }

    void renderFrame(int w, int h)
    {
        applyOrbit();
        cleardevice();
        setviewport(0, 0, w - 1, h - 1, 1);
        wxbgi_render_dds("doughnut_cam");
        setviewport(0, 0, w - 1, h - 1, 0);
    }

    bool   m_ready{false};
    int    m_viewWidth{0};
    int    m_viewHeight{0};
    float  m_phase{0.0f};
    wxTimer m_timer;
};

class MainFrame : public wxFrame
{
public:
    MainFrame()
        : wxFrame(nullptr, wxID_ANY, "CBlit CAD — Rotating Doughnut", wxDefaultPosition, wxSize(980, 800))
    {
        SetBackgroundColour(*wxBLACK);

        auto* canvas = new DoughnutCanvas(this);

        auto* welcomeText = new wxStaticText(this, wxID_ANY, "Welcome to CBlit_CAD",
            wxDefaultPosition, wxDefaultSize, wxALIGN_CENTER);
        welcomeText->SetFont(wxFont(wxFontInfo(24).Bold()));
        welcomeText->SetForegroundColour(*wxWHITE);
        welcomeText->SetBackgroundColour(*wxBLACK);

        auto* sizer = new wxBoxSizer(wxVERTICAL);
        sizer->Add(canvas, 1, wxEXPAND | wxALL, 6);
        sizer->Add(welcomeText, 0, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 12);
        SetSizerAndFit(sizer);

        CreateStatusBar();
        SetStatusText("wx_bgi_graphics 3D doughnut demo");
    }
};

class CBlitApp : public wxApp
{
public:
    bool OnInit() override
    {
        if (!wxApp::OnInit()) {
            return false;
        }

        auto* frame = new MainFrame();
        frame->Show();
        return true;
    }
};

wxIMPLEMENT_APP(CBlitApp);
