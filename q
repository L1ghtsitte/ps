#pragma once
#include "GraphElement.h"

namespace MaltegoClone {

    public ref class GraphEdge
    {
    public:
        GraphElement^ source;
        GraphElement^ target;
        PointF start_point;
        PointF end_point;
        Color color;

        GraphEdge() {
            color = Color::FromArgb(150, 150, 150);
        }

        void UpdateConnectionPoints() {
            if (source != nullptr && target != nullptr) {
                start_point = GetConnectionPoint(source, target->location);
                end_point = GetConnectionPoint(target, source->location);
            }
        }

        void Draw(Graphics^ g) {
            UpdateConnectionPoints();

            // Рисуем линию
            Pen^ pen = gcnew Pen(Color::FromArgb(120, color), 1.5f);
            g->DrawLine(pen, start_point, end_point);

            // Рисуем стрелку
            DrawArrowHead(g);
            delete pen;
        }

    private:
        PointF GetConnectionPoint(GraphElement^ element, PointF reference_point) {
            Rectangle bounds = element->bounds;
            PointF center = PointF(bounds.X + bounds.Width / 2, bounds.Y + bounds.Height / 2);

            float dx = reference_point.X - center.X;
            float dy = reference_point.Y - center.Y;
            float distance = (float)Math::Sqrt(dx * dx + dy * dy);

            if (distance > 0) {
                dx /= distance;
                dy /= distance;
            }

            return PointF(
                center.X + dx * bounds.Width / 2,
                center.Y + dy * bounds.Height / 2);
        }

        void DrawArrowHead(Graphics^ g) {
            float arrow_length = 12.0f;
            float arrow_width = 5.0f;

            float dx = end_point.X - start_point.X;
            float dy = end_point.Y - start_point.Y;
            float length = (float)Math::Sqrt(dx * dx + dy * dy);

            if (length > 0) {
                dx /= length;
                dy /= length;
            }

            // Рассчитываем точку начала стрелки
            PointF arrow_base = PointF(
                end_point.X - dx * arrow_length,
                end_point.Y - dy * arrow_length);

            // Рассчитываем точки стрелки
            PointF arrow_left = PointF(
                arrow_base.X - dy * arrow_width,
                arrow_base.Y + dx * arrow_width);
            
            PointF arrow_right = PointF(
                arrow_base.X + dy * arrow_width,
                arrow_base.Y - dx * arrow_width);

            // Рисуем стрелку
            array<PointF>^ arrow_points = gcnew array<PointF> { end_point, arrow_left, arrow_right };
            SolidBrush^ brush = gcnew SolidBrush(color);
            g->FillPolygon(brush, arrow_points);
            delete brush;
        }
    };
}