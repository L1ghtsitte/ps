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

        void Draw(Graphics^ g)
        {
            Pen^ pen = gcnew Pen(Color::Black, 2);
            g->DrawLine(pen, StartPoint, EndPoint);
            
            // Draw arrow head
            float arrowSize = 8;
            PointF arrowPoint = EndPoint;
            PointF arrowLeft = PointF(
                EndPoint.X - arrowSize,
                EndPoint.Y - arrowSize);
            PointF arrowRight = PointF(
                EndPoint.X - arrowSize,
                EndPoint.Y + arrowSize);
            
            array<PointF>^ arrowPoints = gcnew array<PointF> { arrowPoint, arrowLeft, arrowRight };
            g->FillPolygon(Brushes::Black, arrowPoints);
            
            delete pen;
        }
    };
}