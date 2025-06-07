void SaveToHtml(Object^ sender, EventArgs^ e) {
    SaveFileDialog^ saveDialog = gcnew SaveFileDialog();
    saveDialog->Filter = "HTML Files|*.html|All Files|*.*";
    saveDialog->Title = "Сохранить граф в HTML";

    if (saveDialog->ShowDialog() == Windows::Forms::DialogResult::OK) {
        try {
            StreamWriter^ writer = gcnew StreamWriter(saveDialog->FileName);
            writer->WriteLine("<!DOCTYPE html>");
            writer->WriteLine("<html><head><title>Граф Maltego</title>");
            writer->WriteLine("<style>");
            writer->WriteLine("  .node { position: absolute; border: 1px solid #000; padding: 5px; background: #fff; }");
            writer->WriteLine("  .edge { position: absolute; height: 2px; background: #000; }");
            writer->WriteLine("</style></head><body>");
            
            // Сохраняем узлы
            for each(GraphElement^ element in graph_elements) {
                writer->WriteLine(String::Format(
                    "<div class=\"node\" style=\"left:{0}px;top:{1}px;width:{2}px;height:{3}px;\">{4}</div>",
                    element->location.X, element->location.Y,
                    element->size.Width, element->size.Height,
                    element->text));
            }
            
            // Сохраняем связи
            for each(GraphEdge^ edge in edges) {
                if (edge->source != nullptr && edge->target != nullptr) {
                    PointF start = GetConnectionPoint(edge->source, edge->target->location);
                    PointF end = GetConnectionPoint(edge->target, edge->source->location);
                    
                    writer->WriteLine(String::Format(
                        "<div class=\"edge\" style=\"left:{0}px;top:{1}px;width:{2}px;transform:rotate({3}deg);\"></div>",
                        start.X, start.Y,
                        Math::Sqrt(Math::Pow(end.X - start.X, 2) + Math::Pow(end.Y - start.Y, 2)),
                        Math::Atan2(end.Y - start.Y, end.X - start.X) * 180 / Math::PI));
                }
            }
            
            writer->WriteLine("</body></html>");
            writer->Close();
            
            MessageBox::Show("Граф успешно сохранен в HTML!", "Сохранение завершено",
                MessageBoxButtons::OK, MessageBoxIcon::Information);
        }
        catch (Exception^ ex) {
            MessageBox::Show("Ошибка сохранения: " + ex->Message, "Ошибка",
                MessageBoxButtons::OK, MessageBoxIcon::Error);
        }
    }
}

void LoadFromHtml(Object^ sender, EventArgs^ e) {
    OpenFileDialog^ openDialog = gcnew OpenFileDialog();
    openDialog->Filter = "HTML Files|*.html|All Files|*.*";
    openDialog->Title = "Загрузить граф из HTML";

    if (openDialog->ShowDialog() == Windows::Forms::DialogResult::OK) {
        try {
            graph_elements->Clear();
            edges->Clear();
            
            String^ html = File::ReadAllText(openDialog->FileName);
            
            // Парсинг узлов (упрощенный пример)
            int pos = 0;
            while ((pos = html->IndexOf("<div class=\"node\"", pos)) != -1) {
                int left = ParseHtmlValue(html, "left:", pos);
                int top = ParseHtmlValue(html, "top:", pos);
                int width = ParseHtmlValue(html, "width:", pos);
                int height = ParseHtmlValue(html, "height:", pos);
                
                int textStart = html->IndexOf(">", pos) + 1;
                int textEnd = html->IndexOf("<", textStart);
                String^ text = html->Substring(textStart, textEnd - textStart);
                
                GraphNode^ node = gcnew GraphNode();
                node->location = Point(left, top);
                node->size = Size(width, height);
                node->text = text;
                graph_elements->Add(node);
                
                pos = textEnd;
            }
            
            graph_panel->Invalidate();
            MessageBox::Show("Граф успешно загружен из HTML!", "Загрузка завершена",
                MessageBoxButtons::OK, MessageBoxIcon::Information);
        }
        catch (Exception^ ex) {
            MessageBox::Show("Ошибка загрузки: " + ex->Message, "Ошибка",
                MessageBoxButtons::OK, MessageBoxIcon::Error);
        }
    }
}

int ParseHtmlValue(String^ html, String^ prop, int startPos) {
    int pos = html->IndexOf(prop, startPos) + prop->Length;
    int endPos = html->IndexOf("px", pos);
    return Int32::Parse(html->Substring(pos, endPos - pos));
}