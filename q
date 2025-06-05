// Добавьте в класс MainForm

// Метод для экспорта в HTML с сохранением связей
void ExportToHtmlWithConnections(Object^ sender, EventArgs^ e)
{
    SaveFileDialog^ saveDialog = gcnew SaveFileDialog();
    saveDialog->Filter = "HTML Files|*.html|All Files|*.*";
    saveDialog->Title = "Export Graph to HTML with Connections";
    
    if (saveDialog->ShowDialog() == Windows::Forms::DialogResult::OK)
    {
        try
        {
            StringBuilder^ html = gcnew StringBuilder();
            
            // HTML Header
            html->AppendLine("<!DOCTYPE html>");
            html->AppendLine("<html lang=\"en\">");
            html->AppendLine("<head>");
            html->AppendLine("  <meta charset=\"UTF-8\">");
            html->AppendLine("  <title>Maltego Graph Export</title>");
            html->AppendLine("  <style>");
            html->AppendLine("    body { font-family: Arial, sans-serif; background-color: #f0f0f0; }");
            html->AppendLine("    .graph-container { position: relative; width: 100%; height: 800px; background-color: white; border: 1px solid #ccc; margin: 20px; }");
            html->AppendLine("    .node { position: absolute; border: 1px solid #333; border-radius: 4px; padding: 8px; background-color: #fff; box-shadow: 2px 2px 5px rgba(0,0,0,0.2); }");
            html->AppendLine("    .node-title { font-weight: bold; margin-bottom: 5px; }");
            html->AppendLine("    .node-properties { margin-top: 5px; font-size: 0.9em; }");
            html->AppendLine("    .edge { position: absolute; height: 2px; background-color: #666; transform-origin: 0 0; }");
            html->AppendLine("    .arrow { position: absolute; width: 0; height: 0; border-style: solid; }");
            html->AppendLine("  </style>");
            html->AppendLine("</head>");
            html->AppendLine("<body>");
            html->AppendLine("  <h1>Maltego Graph Export</h1>");
            html->AppendLine("  <div class=\"graph-container\" id=\"graph\">");

            // Словарь для хранения позиций узлов
            Dictionary<int, Point>^ nodePositions = gcnew Dictionary<int, Point>();

            // Экспорт узлов
            for each (GraphElement ^ node in graph_elements)
            {
                nodePositions->Add(node->id, node->location);
                
                html->AppendFormat("    <div class=\"node\" style=\"left:{0}px;top:{1}px;width:{2}px;min-height:{3}px;background-color:{4};\" data-id=\"{5}\">",
                    node->location.X, node->location.Y, node->size.Width, node->size.Height, 
                    ColorToHex(node->color), node->id);
                
                html->AppendFormat("      <div class=\"node-title\">{0}</div>", EscapeHtml(node->text));
                
                if (node->is_expanded && node->properties->Count > 0)
                {
                    html->AppendLine("      <div class=\"node-properties\">");
                    for each (KeyValuePair<String^, String^> pair in node->properties)
                    {
                        html->AppendFormat("        <div><b>{0}:</b> {1}</div>", 
                            EscapeHtml(pair.Key), EscapeHtml(pair.Value));
                    }
                    html->AppendLine("      </div>");
                }
                
                html->AppendLine("    </div>");
            }

            // Экспорт связей с стрелками
            for each (GraphEdge ^ edge in edges)
            {
                if (edge->source == nullptr || edge->target == nullptr)
                    continue;

                Point start = edge->source->location;
                Point end = edge->target->location;
                
                // Вычисляем точку соединения на границе узла
                PointF startConn = GetConnectionPoint(edge->source, end);
                PointF endConn = GetConnectionPoint(edge->target, start);
                
                // Линия связи
                float dx = endConn.X - startConn.X;
                float dy = endConn.Y - startConn.Y;
                float length = (float)Math::Sqrt(dx * dx + dy * dy);
                float angle = (float)(Math::Atan2(dy, dx) * 180.0 / Math::PI);
                
                html->AppendFormat("    <div class=\"edge\" style=\"left:{0}px;top:{1}px;width:{2}px;transform:rotate({3}deg);background-color:{4};\" data-source=\"{5}\" data-target=\"{6}\"></div>",
                    startConn.X, startConn.Y, length, angle, ColorToHex(edge->color), 
                    edge->source->id, edge->target->id);
                
                // Стрелка
                float arrowSize = 8;
                float arrowAngle = 30; // Угол раскрытия стрелки
                
                html->AppendFormat("    <div class=\"arrow\" style=\"left:{0}px;top:{1}px;border-width:0 {2}px {3}px {2}px;border-color:transparent transparent {4} transparent;transform:rotate({5}deg);\"></div>",
                    endConn.X - arrowSize * (float)Math::Cos(angle * Math::PI / 180),
                    endConn.Y - arrowSize * (float)Math::Sin(angle * Math::PI / 180),
                    arrowSize / 2, arrowSize, ColorToHex(edge->color),
                    angle - 90 + arrowAngle);
                
                html->AppendFormat("    <div class=\"arrow\" style=\"left:{0}px;top:{1}px;border-width:0 {2}px {3}px {2}px;border-color:transparent transparent {4} transparent;transform:rotate({5}deg);\"></div>",
                    endConn.X - arrowSize * (float)Math::Cos(angle * Math::PI / 180),
                    endConn.Y - arrowSize * (float)Math::Sin(angle * Math::PI / 180),
                    arrowSize / 2, arrowSize, ColorToHex(edge->color),
                    angle - 90 - arrowAngle);
            }

            // HTML Footer
            html->AppendLine("  </div>");
            html->AppendLine("</body>");
            html->AppendLine("</html>");

            File::WriteAllText(saveDialog->FileName, html->ToString());
            MessageBox::Show("Graph with connections successfully exported to HTML!", "Export Complete", 
                MessageBoxButtons::OK, MessageBoxIcon::Information);
        }
        catch (Exception^ ex)
        {
            MessageBox::Show("Error exporting to HTML: " + ex->Message, "Export Error", 
                MessageBoxButtons::OK, MessageBoxIcon::Error);
        }
    }
}

// Метод для загрузки из HTML с восстановлением связей
void ImportFromHtmlWithConnections(Object^ sender, EventArgs^ e)
{
    OpenFileDialog^ openDialog = gcnew OpenFileDialog();
    openDialog->Filter = "HTML Files|*.html|All Files|*.*";
    openDialog->Title = "Import Graph from HTML with Connections";
    
    if (openDialog->ShowDialog() == Windows::Forms::DialogResult::OK)
    {
        try
        {
            graph_elements->Clear();
            edges->Clear();
            node_id_counter = 1;
            
            String^ html = File::ReadAllText(openDialog->FileName);
            Dictionary<int, GraphElement^>^ nodeMap = gcnew Dictionary<int, GraphElement^>();
            List<Tuple<int, int, Color>^>^ edgeDefinitions = gcnew List<Tuple<int, int, Color>^>();
            
            // Парсинг узлов
            int nodeSearchPos = 0;
            while ((nodeSearchPos = html->IndexOf("<div class=\"node\"", nodeSearchPos)) != -1)
            {
                try
                {
                    // Извлекаем атрибут data-id
                    int idStart = html->IndexOf("data-id=\"", nodeSearchPos) + 9;
                    int idEnd = html->IndexOf("\"", idStart);
                    int id = Int32::Parse(html->Substring(idStart, idEnd - idStart));
                    
                    // Извлекаем стиль
                    int styleStart = html->IndexOf("style=\"", nodeSearchPos) + 7;
                    int styleEnd = html->IndexOf("\"", styleStart);
                    String^ style = html->Substring(styleStart, styleEnd - styleStart);
                    
                    int x = ParseHtmlStyleValueInt(style, "left");
                    int y = ParseHtmlStyleValueInt(style, "top");
                    int width = ParseHtmlStyleValueInt(style, "width");
                    int height = ParseHtmlStyleValueInt(style, "min-height");
                    String^ colorStr = ParseHtmlStyleValueString(style, "background-color");
                    
                    // Извлекаем заголовок
                    int titleStart = html->IndexOf("node-title\">", nodeSearchPos) + 12;
                    int titleEnd = html->IndexOf("<", titleStart);
                    String^ title = html->Substring(titleStart, titleEnd - titleStart);
                    
                    // Создаем узел
                    GraphNode^ node = gcnew GraphNode();
                    node->id = id;
                    node->text = UnescapeHtml(title);
                    node->location = Point(x, y);
                    node->size = Size(width, height);
                    node->color = ParseHtmlColor(colorStr);
                    
                    // Парсим свойства
                    int propsStart = html->IndexOf("node-properties", nodeSearchPos);
                    if (propsStart != -1)
                    {
                        propsStart = html->IndexOf(">", propsStart) + 1;
                        int propsEnd = html->IndexOf("</div>", propsStart);
                        String^ propsHtml = html->Substring(propsStart, propsEnd - propsStart);
                        
                        int propPos = 0;
                        while ((propPos = propsHtml->IndexOf("<div>", propPos)) != -1)
                        {
                            propPos += 5;
                            int propEnd = propsHtml->IndexOf("</div>", propPos);
                            String^ propText = propsHtml->Substring(propPos, propEnd - propPos);
                            
                            int colonPos = propText->IndexOf(":");
                            if (colonPos != -1)
                            {
                                String^ key = UnescapeHtml(propText->Substring(0, colonPos)->Trim());
                                String^ value = UnescapeHtml(propText->Substring(colonPos + 1)->Trim());
                                node->properties->Add(key, value);
                            }
                            propPos = propEnd;
                        }
                        node->is_expanded = true;
                    }
                    
                    graph_elements->Add(node);
                    nodeMap->Add(id, node);
                    node_id_counter = Math::Max(node_id_counter, id + 1);
                    nodeSearchPos = styleEnd;
                }
                catch (Exception^ ex)
                {
                    nodeSearchPos++;
                    if (nodeSearchPos >= html->Length) break;
                }
            }
            
            // Парсинг связей
            int edgeSearchPos = 0;
            while ((edgeSearchPos = html->IndexOf("<div class=\"edge\"", edgeSearchPos)) != -1)
            {
                try
                {
                    // Извлекаем source и target
                    int sourceStart = html->IndexOf("data-source=\"", edgeSearchPos) + 13;
                    int sourceEnd = html->IndexOf("\"", sourceStart);
                    int sourceId = Int32::Parse(html->Substring(sourceStart, sourceEnd - sourceStart));
                    
                    int targetStart = html->IndexOf("data-target=\"", edgeSearchPos) + 13;
                    int targetEnd = html->IndexOf("\"", targetStart);
                    int targetId = Int32::Parse(html->Substring(targetStart, targetEnd - targetStart));
                    
                    // Извлекаем цвет
                    int styleStart = html->IndexOf("style=\"", edgeSearchPos) + 7;
                    int styleEnd = html->IndexOf("\"", styleStart);
                    String^ style = html->Substring(styleStart, styleEnd - styleStart);
                    String^ colorStr = ParseHtmlStyleValueString(style, "background-color");
                    
                    edgeDefinitions->Add(Tuple::Create(sourceId, targetId, ParseHtmlColor(colorStr)));
                    edgeSearchPos = styleEnd;
                }
                catch (Exception^ ex)
                {
                    edgeSearchPos++;
                    if (edgeSearchPos >= html->Length) break;
                }
            }
            
            // Восстанавливаем связи
            for each (Tuple<int, int, Color>^ edgeDef in edgeDefinitions)
            {
                if (nodeMap->ContainsKey(edgeDef->Item1) && nodeMap->ContainsKey(edgeDef->Item2))
                {
                    GraphEdge^ edge = gcnew GraphEdge();
                    edge->source = nodeMap[edgeDef->Item1];
                    edge->target = nodeMap[edgeDef->Item2];
                    edge->color = edgeDef->Item3;
                    edges->Add(edge);
                }
            }
            
            graph_panel->Invalidate();
            MessageBox::Show(String::Format("Imported {0} nodes and {1} edges with connections", 
                graph_elements->Count, edges->Count), "Import Complete", 
                MessageBoxButtons::OK, MessageBoxIcon::Information);
        }
        catch (Exception^ ex)
        {
            MessageBox::Show("Error importing HTML with connections: " + ex->Message, "Import Error", 
                MessageBoxButtons::OK, MessageBoxIcon::Error);
        }
    }
}

// Вспомогательный метод для получения точки соединения
PointF GetConnectionPoint(GraphElement^ element, PointF referencePoint)
{
    Rectangle bounds = element->bounds;
    PointF center = PointF(bounds.X + bounds.Width / 2.0f, bounds.Y + bounds.Height / 2.0f);
    
    float dx = referencePoint.X - center.X;
    float dy = referencePoint.Y - center.Y;
    float distance = (float)Math::Sqrt(dx * dx + dy * dy);
    
    if (distance > 0)
    {
        dx /= distance;
        dy /= distance;
    }
    
    // Находим точку пересечения с границей прямоугольника
    float ratio = Math::Min(
        Math::Abs((bounds.Width / 2) / dx),
        Math::Abs((bounds.Height / 2) / dy)
    );
    
    return PointF(
        center.X + dx * ratio,
        center.Y + dy * ratio
    );
}