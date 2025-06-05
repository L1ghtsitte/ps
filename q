private:
    // Вспомогательные методы для парсинга HTML
    int ParseHtmlStyleValueInt(String^ style, String^ propertyName)
    {
        int propPos = style->IndexOf(propertyName);
        if (propPos == -1) return 0;
        
        propPos += propertyName->Length + 1;
        int endPos = style->IndexOf(";", propPos);
        if (endPos == -1) endPos = style->Length;
        
        String^ value = style->Substring(propPos, endPos - propPos)->Trim();
        
        // Удаляем "px" если есть
        if (value->EndsWith("px")) value = value->Substring(0, value->Length - 2);
        return Int32::Parse(value);
    }

    float ParseHtmlStyleValueFloat(String^ style, String^ propertyName)
    {
        int propPos = style->IndexOf(propertyName);
        if (propPos == -1) return 0.0f;
        
        propPos += propertyName->Length + 1;
        int endPos = style->IndexOf(";", propPos);
        if (endPos == -1) endPos = style->Length;
        
        String^ value = style->Substring(propPos, endPos - propPos)->Trim();
        
        // Удаляем "deg" если есть
        if (value->EndsWith("deg")) value = value->Substring(0, value->Length - 3);
        return Single::Parse(value);
    }

    String^ ParseHtmlStyleValueString(String^ style, String^ propertyName)
    {
        int propPos = style->IndexOf(propertyName);
        if (propPos == -1) return String::Empty;
        
        propPos += propertyName->Length + 1;
        int endPos = style->IndexOf(";", propPos);
        if (endPos == -1) endPos = style->Length;
        
        return style->Substring(propPos, endPos - propPos)->Trim();
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
        return Color::Gray;
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

    GraphElement^ FindClosestNode(Dictionary<Point, GraphElement^>^ nodesMap, Point point)
    {
        GraphElement^ closestNode = nullptr;
        float minDistance = 1000000;
        
        for each (KeyValuePair<Point, GraphElement^> pair in nodesMap)
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

public:
    void ImportFromHtml(Object^ sender, EventArgs^ e)
    {
        OpenFileDialog^ openDialog = gcnew OpenFileDialog();
        openDialog->Filter = "HTML Files|*.html|All Files|*.*";
        openDialog->Title = "Import Graph from HTML";
        
        if (openDialog->ShowDialog() == Windows::Forms::DialogResult::OK)
        {
            try
            {
                graph_elements->Clear();
                edges->Clear();
                node_id_counter = 1;
                
                String^ html = File::ReadAllText(openDialog->FileName);
                Dictionary<Point, GraphElement^>^ positionMap = gcnew Dictionary<Point, GraphElement^>();
                List<Tuple<Point, Point, Color>^>^ edgeDefinitions = gcnew List<Tuple<Point, Point, Color>^>();
                
                // Parse nodes
                int nodeSearchPos = 0;
                while ((nodeSearchPos = html->IndexOf("<div class=\"node\"", nodeSearchPos)) != -1)
                {
                    try
                    {
                        int styleStart = html->IndexOf("style=\"", nodeSearchPos) + 7;
                        int styleEnd = html->IndexOf("\"", styleStart);
                        String^ style = html->Substring(styleStart, styleEnd - styleStart);
                        
                        int x = ParseHtmlStyleValueInt(style, "left");
                        int y = ParseHtmlStyleValueInt(style, "top");
                        int width = ParseHtmlStyleValueInt(style, "width");
                        int height = ParseHtmlStyleValueInt(style, "min-height");
                        String^ colorStr = ParseHtmlStyleValueString(style, "background-color");
                        
                        int titleStart = html->IndexOf("node-title\">", nodeSearchPos) + 12;
                        int titleEnd = html->IndexOf("<", titleStart);
                        String^ title = html->Substring(titleStart, titleEnd - titleStart);
                        
                        GraphNode^ node = gcnew GraphNode();
                        node->id = node_id_counter++;
                        node->text = UnescapeHtml(title);
                        node->location = Point(x, y);
                        node->size = Size(width, height);
                        node->color = ParseHtmlColor(colorStr);
                        
                        // Parse properties
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
                        positionMap->Add(node->location, node);
                        nodeSearchPos = styleEnd;
                    }
                    catch (Exception^ ex)
                    {
                        nodeSearchPos++;
                        if (nodeSearchPos >= html->Length) break;
                    }
                }
                
                // Parse edges
                int edgeSearchPos = 0;
                while ((edgeSearchPos = html->IndexOf("<div class=\"edge\"", edgeSearchPos)) != -1)
                {
                    try
                    {
                        int styleStart = html->IndexOf("style=\"", edgeSearchPos) + 7;
                        int styleEnd = html->IndexOf("\"", styleStart);
                        String^ style = html->Substring(styleStart, styleEnd - styleStart);
                        
                        int startX = ParseHtmlStyleValueInt(style, "left");
                        int startY = ParseHtmlStyleValueInt(style, "top");
                        float length = ParseHtmlStyleValueFloat(style, "width");
                        float angle = ParseHtmlStyleValueFloat(style, "rotate");
                        String^ colorStr = ParseHtmlStyleValueString(style, "background-color");
                        
                        float endX = startX + length * (float)Math::Cos(angle * Math::PI / 180);
                        float endY = startY + length * (float)Math::Sin(angle * Math::PI / 180);
                        
                        edgeDefinitions->Add(Tuple::Create(
                            Point(startX, startY),
                            Point((int)endX, (int)endY),
                            ParseHtmlColor(colorStr)
                        ));
                        
                        edgeSearchPos = styleEnd;
                    }
                    catch (Exception^ ex)
                    {
                        edgeSearchPos++;
                        if (edgeSearchPos >= html->Length) break;
                    }
                }
                
                // Create edges
                for each (Tuple<Point, Point, Color>^ edgeDef in edgeDefinitions)
                {
                    GraphElement^ source = FindClosestNode(positionMap, edgeDef->Item1);
                    GraphElement^ target = FindClosestNode(positionMap, edgeDef->Item2);
                    
                    if (source != nullptr && target != nullptr)
                    {
                        GraphEdge^ edge = gcnew GraphEdge();
                        edge->source = source;
                        edge->target = target;
                        edge->color = edgeDef->Item3;
                        edges->Add(edge);
                    }
                }
                
                graph_panel->Invalidate();
                MessageBox::Show(String::Format("Imported {0} nodes and {1} edges", 
                    graph_elements->Count, edges->Count), "Import Complete", 
                    MessageBoxButtons::OK, MessageBoxIcon::Information);
            }
            catch (Exception^ ex)
            {
                MessageBox::Show("Error importing HTML: " + ex->Message, "Error", 
                    MessageBoxButtons::OK, MessageBoxIcon::Error);
            }
        }
    }