#include <cmath>
#include <string>
#include <memory>
#include "wx/wx.h"
#include "wx/defs.h"
#include "wx_bgi_wx.h"
#include "wx_bgi.h"
#include "wx_bgi_ext.h"
#include "wx_bgi_3d.h"
#include "wx_bgi_solid.h"
#include "wx_bgi_dds.h"

using namespace bgi;

// Push MSVC warning state and disable padding warning for this class.
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable:4820)
#endif
class DoughnutCanvas : public wxbgi::WxBgiCanvas
{
public:
    // Explicitly delete copy/move operations to make intent clear and avoid
    // warnings about implicitly deleted special members.
    DoughnutCanvas(const DoughnutCanvas&) = delete;
    DoughnutCanvas& operator=(const DoughnutCanvas&) = delete;
    DoughnutCanvas(DoughnutCanvas&&) = delete;
    DoughnutCanvas& operator=(DoughnutCanvas&&) = delete;

    explicit DoughnutCanvas(wxWindow* parent)
        : WxBgiCanvas(parent, wxID_ANY, wxDefaultPosition, wxDefaultSize)
    {
        // Construct the timer after 'this' is valid to avoid using 'this' in
        // the member initializer list (prevents C4355 warning).
        m_timer = std::make_unique<wxTimer>(this);
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
            if (m_timer) m_timer->Start(30);
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

        settextstyle(MODERN_ROBOTO_FONT, HORIZ_DIR, 2);
        setcolor(YELLOW);
        std::string line = "Roboto: 3D doughnut demo";
        outtextxy(0.13f, 0.05f, line.data());

        wxbgi_solid_set_draw_mode(WXBGI_SOLID_SMOOTH);
        wxbgi_solid_set_edge_color(WHITE);
        wxbgi_solid_set_face_color(CYAN);
        wxbgi_solid_set_light_dir(-0.4f, 0.5f, 0.7f);
        wxbgi_solid_set_fill_light(0.15f, -0.25f, -0.45f, 0.35f);
        wxbgi_solid_set_ambient(0.22f);
        wxbgi_solid_set_diffuse(0.70f);
        wxbgi_solid_set_specular(0.45f, 56.0f);

        wxbgi_solid_set_face_color(wxbgi_alloc_color(235, 78, 38));
        wxbgi_solid_set_edge_color(WHITE);
        wxbgi_solid_box(2.4f, 0.0f, 3.0f, 1.5f, 1.2f, 1.6f);

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

    // Reorder members to reduce padding: place larger types first.
    int    m_viewWidth{0};
    int    m_viewHeight{0};
    float  m_phase{0.0f};
    bool   m_ready{false};
    std::unique_ptr<wxTimer> m_timer;
};
#ifdef _MSC_VER
#pragma warning(pop)
#endif

class MainFrame : public wxFrame
{
public:
    MainFrame(const MainFrame&) = delete;
    MainFrame& operator=(const MainFrame&) = delete;
    MainFrame(MainFrame&&) = delete;
    MainFrame& operator=(MainFrame&&) = delete;
public:
    MainFrame()
        : wxFrame(nullptr, wxID_ANY, "CBlit CAD - Rotating Doughnut", wxDefaultPosition, wxSize(980, 800))
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
        SetStatusText("Phoenix_gi - 3D doughnut demo");
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

// Make application class non-copyable/movable to silence warnings about
// implicitly deleted special members.
class CBlitAppNonCopyable : public CBlitApp {
public:
    CBlitAppNonCopyable() = default;
    CBlitAppNonCopyable(const CBlitAppNonCopyable&) = delete;
    CBlitAppNonCopyable& operator=(const CBlitAppNonCopyable&) = delete;
    CBlitAppNonCopyable(CBlitAppNonCopyable&&) = delete;
    CBlitAppNonCopyable& operator=(CBlitAppNonCopyable&&) = delete;
};

wxIMPLEMENT_APP(CBlitAppNonCopyable);
