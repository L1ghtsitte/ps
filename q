#pragma once
#include "GraphElement.h"

namespace MaltegoClone {

    public ref class GraphEdge
    {
    public:
        GraphElement^ Source;
        GraphElement^ Target;
        PointF StartPoint;
        PointF EndPoint;

        void UpdateConnectionPoints()
        {
            if (Source != nullptr && Target != nullptr)
            {
                StartPoint = GetConnectionPoint(Source, Target->Location);
                EndPoint = GetConnectionPoint(Target, Source->Location);
            }
        }

        void Draw(Graphics^ g)
        {
            UpdateConnectionPoints();
            
            Pen^ pen = gcnew Pen(Color::FromArgb(150, Color::Black), 1.5f);
            g->DrawLine(pen, StartPoint, EndPoint);
            DrawArrowHead(g);
            delete pen;
        }

    private:
        PointF GetConnectionPoint(GraphElement^ element, PointF referencePoint)
        {
            Rectangle bounds = element->Bounds;
            PointF center = PointF(bounds.X + bounds.Width / 2, bounds.Y + bounds.Height / 2);
            
            float dx = referencePoint.X - center.X;
            float dy = referencePoint.Y - center.Y;
            float distance = (float)Math::Sqrt(dx * dx + dy * dy);
            
            if (distance > 0)
            {
                dx /= distance;
                dy /= distance;
            }
            
            return PointF(
                center.X + dx * bounds.Width / 2,
                center.Y + dy * bounds.Height / 2);
        }

        void DrawArrowHead(Graphics^ g)
        {
            float arrowSize = 8.0f;
            float arrowWidth = 4.0f;
            
            float dx = EndPoint.X - StartPoint.X;
            float dy = EndPoint.Y - StartPoint.Y;
            float length = (float)Math::Sqrt(dx * dx + dy * dy);
            
            if (length > 0)
            {
                dx /= length;
                dy /= length;
            }
            
            PointF arrowTip = EndPoint;
            PointF arrowLeft = PointF(
                arrowTip.X - dx * arrowSize - dy * arrowWidth,
                arrowTip.Y - dy * arrowSize + dx * arrowWidth);
            PointF arrowRight = PointF(
                arrowTip.X - dx * arrowSize + dy * arrowWidth,
                arrowTip.Y - dy * arrowSize - dx * arrowWidth);
            
            array<PointF>^ arrowPoints = gcnew array<PointF> { arrowTip, arrowLeft, arrowRight };
            g->FillPolygon(Brushes::Black, arrowPoints);
        }
    };
}