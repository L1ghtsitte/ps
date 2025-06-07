// GraphEdge.h
#pragma once
#include "GraphElement.h"

using namespace System;
using namespace System::Drawing;

namespace MaltegoClone {
    public ref class GraphEdge {
    public:
        GraphElement^ source;
        GraphElement^ target;
        PointF start_point;
        PointF end_point;
        Color color;
        float width;

        GraphEdge() {
            color = Color::FromArgb(120, 120, 120);
            width = 2.0f;
        }

        void Draw(Graphics^ g) {
            if (source == nullptr || target == nullptr) return;

            // Обновляем точки соединения
            start_point = GetConnectionPoint(source, PointF(target->location.X + target->size.Width/2, 
                                            target->location.Y + target->size.Height/2));
            end_point = GetConnectionPoint(target, PointF(source->location.X + source->size.Width/2, 
                                          source->location.Y + source->size.Height/2));

            // Рисуем линию с тенью
            Pen^ pen = gcnew Pen(Color::FromArgb(50, 0, 0, 0), width + 1);
            g->DrawLine(pen, start_point.X + 2, start_point.Y + 2, end_point.X + 2, end_point.Y + 2);

            pen = gcnew Pen(color, width);
            g->DrawLine(pen, start_point, end_point);

            // Рисуем стрелку
            DrawArrowHead(g);
            delete pen;
        }

    private:
        PointF GetConnectionPoint(GraphElement^ element, PointF reference_point) {
            System::Drawing::Rectangle bounds = element->Bounds;
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

            PointF adjusted_end = PointF(
                end_point.X - dx * arrow_length * 0.7f,
                end_point.Y - dy * arrow_length * 0.7f);

            PointF arrow_left = PointF(
                adjusted_end.X - dy * arrow_width,
                adjusted_end.Y + dx * arrow_width);

            PointF arrow_right = PointF(
                adjusted_end.X + dy * arrow_width,
                adjusted_end.Y - dx * arrow_width);

            array<PointF>^ arrow_points = gcnew array<PointF>{ end_point, arrow_left, arrow_right };
            SolidBrush^ brush = gcnew SolidBrush(color);
            g->FillPolygon(brush, arrow_points);
            delete brush;
        }
    };
}