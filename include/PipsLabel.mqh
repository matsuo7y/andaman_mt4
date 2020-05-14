//+------------------------------------------------------------------+
//|                                                    PipsLabel.mqh |
//|                                     Copyright 2020, Yuki Matsuo. |
//+------------------------------------------------------------------+
#include <Controls\Edit.mqh>
#include <Controls\WndContainer.mqh>
#include <Charts\Chart.mqh>

#define PL_WIDTH  (55)
#define PL_HEIGHT (25)

#define FONT_SIZE (14)

class CPipsLabel : public CWndContainer
  {
private:
   CEdit            m_pips_label;

public:
                    CPipsLabel(void) {};
                    ~CPipsLabel(void) {};

   bool             Create(const long chart,const string name,const int subwin,const int x1,const int y1);
   virtual bool     OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   bool             Pips(double pips);
   bool             Color(color c);

protected:
   virtual bool     CreatePipsLabel(void);

   virtual void     OnClickPipsLabel(void);

   virtual bool     OnDialogDragStart(void);
   virtual bool     OnDialogDragProcess(void);
   virtual bool     OnDialogDragEnd(void);

   bool             OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam) { return(false); };
  };

EVENT_MAP_BEGIN(CPipsLabel)
ON_EVENT(ON_CLICK,m_pips_label,OnClickPipsLabel)
ON_EVENT(ON_DRAG_START,m_pips_label,OnDialogDragStart)
ON_EVENT_PTR(ON_DRAG_PROCESS,m_drag_object,OnDialogDragProcess)
ON_EVENT_PTR(ON_DRAG_END,m_drag_object,OnDialogDragEnd)
ON_OTHER_EVENTS(OnDefault)
EVENT_MAP_END(CWndContainer)

bool CPipsLabel::Create(const long chart,const string name,const int subwin,const int x1,const int y1)
  {
   if(!CWndContainer::Create(chart, name, subwin, x1, y1, x1+PL_WIDTH, y1+PL_HEIGHT))
      return(false);

   if(!CreatePipsLabel())
      return(false);

   return(true);
  }

bool CPipsLabel::Pips(double pips)
  {
   if(!m_pips_label.Text(DoubleToStr(pips, 1)))
      return(false);

   return(true);
  }

bool CPipsLabel::Color(color c)
  {
   if(!m_pips_label.Color(c))
      return(false);

   return(true);
  }

bool CPipsLabel::CreatePipsLabel(void)
  {
   if(!m_pips_label.Create(m_chart_id, m_name+"Label", m_subwin, 0, 0, Width(), Height()))
      return(false);

   if(!m_pips_label.Text(DoubleToStr(10.1, 1)))
      return(false);
   if(!m_pips_label.Color(Blue))
      return(false);
   if(!m_pips_label.FontSize(FONT_SIZE))
      return(false);
   if(!m_pips_label.ReadOnly(true))
      return(false);

   if(!Add(m_pips_label))
      return(false);

   m_pips_label.PropFlags(WND_PROP_FLAG_CAN_DRAG);

   return(true);
  }

void CPipsLabel::OnClickPipsLabel(void)
  {
  }

bool CPipsLabel::OnDialogDragStart(void)
  {
   if(m_drag_object==NULL)
     {
      m_drag_object=new CDragWnd;
      if(m_drag_object==NULL)
         return(false);
     }

   int x1=Left()-CONTROLS_DRAG_SPACING;
   int y1=Top()-CONTROLS_DRAG_SPACING;
   int x2=Right()+CONTROLS_DRAG_SPACING;
   int y2=Bottom()+CONTROLS_DRAG_SPACING;

   m_drag_object.Create(m_chart_id,"",m_subwin,x1,y1,x2,y2);
   m_drag_object.PropFlags(WND_PROP_FLAG_CAN_DRAG);

   CChart chart;
   chart.Attach(m_chart_id);
   m_drag_object.Limits(-CONTROLS_DRAG_SPACING,-CONTROLS_DRAG_SPACING,
                        chart.WidthInPixels()+CONTROLS_DRAG_SPACING,
                        chart.HeightInPixels(m_subwin)+CONTROLS_DRAG_SPACING);
   chart.Detach();

   m_drag_object.MouseX(m_pips_label.MouseX());
   m_drag_object.MouseY(m_pips_label.MouseY());
   m_drag_object.MouseFlags(m_pips_label.MouseFlags());

   return(true);
  }

bool CPipsLabel::OnDialogDragProcess(void)
  {
   if(m_drag_object==NULL)
      return(false);

   int x=m_drag_object.Left()+50;
   int y=m_drag_object.Top()+50;

   Move(x,y);
   return(true);
  }

bool CPipsLabel::OnDialogDragEnd(void)
  {
   if(m_drag_object!=NULL)
     {
      m_pips_label.MouseFlags(m_drag_object.MouseFlags());
      delete m_drag_object;
      m_drag_object=NULL;
     }

   return(true);
  }