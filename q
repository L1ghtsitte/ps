void ImportFromHtml(Object^ sender, EventArgs^ e)
{
    OpenFileDialog^ openDialog = gcnew OpenFileDialog();
    openDialog->Filter = "HTML Files|*.html|All Files|*.*";
    openDialog->Title = "Import Graph from HTML";
    
    if (openDialog->ShowDialog() == Windows::Forms::DialogResult::OK)
    {
        try
        {
            // Очищаем текущий граф
            graph_elements->Clear();
            edges->Clear();
            node_id_counter = 1;
            
            String^ html = File::ReadAllText(openDialog->FileName);
            
            // Словарь для временного хранения связей (sourceId -> targetId)
            Dictionary<int, List<int>^>^ tempEdges = gcnew Dictionary<int, List<int>^>();
            Dictionary<int, GraphElement^>^ nodesMap = gcnew Dictionary<int, GraphElement^>();
            
            // Парсим узлы
            int nodeIndex = 0;
            int nodeSearchPos = 0;
            while ((nodeSearchPos = html->IndexOf("<div class=\"node\"", nodeSearchPos)) != -1)
            {
                // Извлекаем стиль узла
                int styleStart = html->IndexOf("style=\"", nodeSearchPos) + 7;
                int styleEnd = html->IndexOf("\"", styleStart);
                String^ style = html->Substring(styleStart, styleEnd - styleStart);
                
                // Парсим координаты и размеры
                int x = ParseHtmlStyleValue(style, "left");
                int y = ParseHtmlStyleValue(style, "top");
                int width = ParseHtmlStyleValue(style, "width");
                int height = ParseHtmlStyleValue(style, "min-height");
                String^ color = ParseHtmlStyleValue(style, "background-color", true);
                
                // Извлекаем заголовок узла
                int titleStart = html->IndexOf("node-title\">", nodeSearchPos) + 12;
                int titleEnd = html->IndexOf("<", titleStart);
                String^ title = html->Substring(titleStart, titleEnd - titleStart);
                
                // Создаем новый узел
                GraphNode^ node = gcnew GraphNode();
                node->id = node_id_counter++;
                node->text = UnescapeHtml(title);
                node->location = Point(x, y);
                node->size = Size(width, height);
                node->color = ParseHtmlColor(color);
                
                // Парсим свойства узла (если есть)
                int propsStart = html->IndexOf("node-properties", nodeSearchPos);
                if (propsStart != -1)
                {
                    propsStart = html->IndexOf(">", propsStart) + 1;
                    int propsEnd = html->IndexOf("</div>", propsStart);
                    String^ propsHtml = html->Substring(propsStart, propsEnd - propsStart);
                    
                    // Парсим отдельные свойства
                    int propPos = 0;
                    while ((propPos = propsHtml->IndexOf("<div>", propPos)) != -1)
                    {
                        propPos += 5;
                        int propEnd = propsHtml->IndexOf("</div>", propPos);
                        String^ propText = propsHtml->Substring(propPos, propEnd - propPos);
                        
                        // Разделяем ключ и значение
                        int colonPos = propText->IndexOf(":");
                        if (colonPos != -1)
                        {
                            String^ key = UnescapeHtml(propText->Substring(0, colonPos)->Trim();
                            String^ value = UnescapeHtml(propText->Substring(colonPos + 1)->Trim();
                            node->properties->Add(key, value);
                        }
                        propPos = propEnd;
                    }
                    node->is_expanded = true;
                }
                
                graph_elements->Add(node);
                nodesMap->Add(nodeIndex, node);
                nodeIndex++;
                nodeSearchPos = styleEnd;
            }
            
            // Парсим связи между узлами
            int edgeSearchPos = 0;
            while ((edgeSearchPos = html->IndexOf("<div class=\"edge\"", edgeSearchPos)) != -1)
            {
                // Извлекаем стиль связи
                int styleStart = html->IndexOf("style=\"", edgeSearchPos) + 7;
                int styleEnd = html->IndexOf("\"", styleStart);
                String^ style = html->Substring(styleStart, styleEnd - styleStart);
                
                // Парсим координаты начала
                int startX = ParseHtmlStyleValue(style, "left");
                int startY = ParseHtmlStyleValue(style, "top");
                
                // Находим ближайшие узлы к началу и концу связи
                GraphElement^ sourceNode = FindClosestNode(nodesMap, Point(startX, startY));
                
                float length = ParseHtmlStyleValue(style, "width");
                float angle = ParseHtmlStyleValue(style, "rotate", false, true);
                
                // Вычисляем конечные координаты
                float endX = startX + length * (float)Math::Cos(angle * Math::PI / 180);
                float endY = startY + length * (float)Math::Sin(angle * Math::PI / 180);
                
                GraphElement^ targetNode = FindClosestNode(nodesMap, Point((int)endX, (int)endY));
                
                if (sourceNode != nullptr && targetNode != nullptr)
                {
                    GraphEdge^ edge = gcnew GraphEdge();
                    edge->source = sourceNode;
                    edge->target = targetNode;
                    edge->color = ParseHtmlColor(ParseHtmlStyleValue(style, "background-color", true));
                    edges->Add(edge);
                }
                
                edgeSearchPos = styleEnd;
            }
            
            graph_panel->Invalidate();
            MessageBox::Show(String::Format("Successfully imported {0} nodes and {1} edges", 
                graph_elements->Count, edges->Count), "Import Complete", 
                MessageBoxButtons::OK, MessageBoxIcon::Information);
        }
        catch (Exception^ ex)
        {
            MessageBox::Show("Error importing from HTML: " + ex->Message, "Import Error", 
                MessageBoxButtons::OK, MessageBoxIcon::Error);
        }
    }
}

// Вспомогательные методы для парсинга HTML
int ParseHtmlStyleValue(String^ style, String^ propertyName, bool isString = false, bool isFloat = false)
{
    int propPos = style->IndexOf(propertyName);
    if (propPos == -1) return 0;
    
    propPos += propertyName->Length + 1;
    int endPos = style->IndexOf(";", propPos);
    if (endPos == -1) endPos = style->Length;
    
    String^ value = style->Substring(propPos, endPos - propPos)->Trim();
    
    if (isString) return value;
    if (isFloat) return Single::Parse(value->Replace("deg", ""));
    
    // Удаляем "px" если есть
    if (value->EndsWith("px")) value = value->Substring(0, value->Length - 2);
    return Int32::Parse(value);
}

Color ParseHtmlColor(String^ colorStr)
{
    if (colorStr->StartsWith("#") && colorStr->Length == 7)
    {
        int r = Int32::Parse(colorStr->Substring(1, 2), System::Globalization::NumberStyles::HexNumber);
        int g = Int32::Parse(colorStr->Substring(3, 2), System::Globalization::NumberStyles::HexNumber);
        int b = Int32::Parse(colorStr->Substring(5, 2), System::Globalization::NumberStyles::HexNumber);
        return Color::FromArgb(r, g, b);
    }
    return Color::Gray; // По умолчанию
}

String^ UnescapeHtml(String^ input)
{
    if (String::IsNullOrEmpty(input)) return String::Empty;
    return input->Replace("&amp;", "&")
                ->Replace("&lt;", "<")
                ->Replace("&gt;", ">")
                ->Replace("&quot;", "\"")
                ->Replace("&#39;", "'");
}

GraphElement^ FindClosestNode(Dictionary<int, GraphElement^>^ nodesMap, Point point)
{
    GraphElement^ closestNode = nullptr;
    float minDistance = 1000000; // Большое начальное значение
    
    for each (KeyValuePair<int, GraphElement^> pair in nodesMap)
    {
        Rectangle bounds = pair.Value->bounds;
        Point center(bounds.X + bounds.Width / 2, bounds.Y + bounds.Height / 2);
        
        float dx = center.X - point.X;
        float dy = center.Y - point.Y;
        float distance = (float)Math::Sqrt(dx * dx + dy * dy);
        
        if (distance < minDistance)
        {
            minDistance = distance;
            closestNode = pair.Value;
        }
    }
    
    return closestNode;
}