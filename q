private:
    // Add these to the private section of MainForm
    float zoomFactor;
    PointF zoomCenter;

    void SaveProject(String^ filePath) {
        try {
            StringWriter^ sw = gcnew StringWriter();

            // Save elements
            sw->WriteLine("[Elements]");
            for each(GraphElement ^ element in graph_elements) {
                sw->WriteLine("---");
                sw->Write(element->Serialize());
            }

            // Save edges
            sw->WriteLine("\n[Edges]");
            for each(GraphEdge ^ edge in edges) {
                sw->WriteLine("---");
                sw->Write(edge->Serialize());
            }

            // Save settings
            sw->WriteLine("\n[Settings]");
            sw->WriteLine("ScrollX:" + h_scroll->Value);
            sw->WriteLine("ScrollY:" + v_scroll->Value);

            File::WriteAllText(filePath, sw->ToString());
            MessageBox::Show("Project saved successfully!", "Save Project",
                MessageBoxButtons::OK, MessageBoxIcon::Information);
        }
        catch (Exception^ ex) {
            MessageBox::Show("Error saving project: " + ex->Message, "Error",
                MessageBoxButtons::OK, MessageBoxIcon::Error);
        }
    }

    void LoadProject(String^ filePath) {
        try {
            array<String^>^ lines = File::ReadAllLines(filePath);
            Dictionary<int, GraphElement^>^ elementMap = gcnew Dictionary<int, GraphElement^>();
            List<array<String^>^>^ elementBlocks = gcnew List<array<String^>^>();
            List<array<String^>^>^ edgeBlocks = gcnew List<array<String^>^>();
            int scrollX = 0, scrollY = 0;

            String^ currentSection = "";
            List<String^>^ currentBlock = gcnew List<String^>();

            for each(String ^ line in lines) {
                if (line == "[Elements]") { currentSection = "Elements"; continue; }
                else if (line == "[Edges]") { currentSection = "Edges"; continue; }
                else if (line == "[Settings]") { currentSection = "Settings"; continue; }

                if (line == "---") {
                    if (currentBlock->Count > 0) {
                        if (currentSection == "Elements")
                            elementBlocks->Add(currentBlock->ToArray());
                        else if (currentSection == "Edges")
                            edgeBlocks->Add(currentBlock->ToArray());
                        currentBlock->Clear();
                    }
                    continue;
                }

                if (currentSection == "Settings") {
                    if (line->StartsWith("ScrollX:")) scrollX = Int32::Parse(line->Substring(8));
                    else if (line->StartsWith("ScrollY:")) scrollY = Int32::Parse(line->Substring(8));
                }
                else {
                    currentBlock->Add(line);
                }
            }

            // Clear current project
            graph_elements->Clear();
            edges->Clear();

            // Load elements
            for each(array<String^> ^ block in elementBlocks) {
                GraphElement^ element = GraphElement::Deserialize(block);
                graph_elements->Add(element);
                elementMap->Add(element->id, element);
                node_id_counter = Math::Max(node_id_counter, element->id + 1);
            }

            // Load edges
            for each(array<String^> ^ block in edgeBlocks) {
                GraphEdge^ edge = GraphEdge::Deserialize(block, elementMap);
                if (edge->source != nullptr && edge->target != nullptr) {
                    edges->Add(edge);
                }
            }

            // Set scroll
            h_scroll->Value = scrollX;
            v_scroll->Value = scrollY;

            graph_panel->Invalidate();
            MessageBox::Show(String::Format("Project loaded: {0} elements, {1} edges",
                graph_elements->Count, edges->Count), "Load Project",
                MessageBoxButtons::OK, MessageBoxIcon::Information);
        }
        catch (Exception^ ex) {
            MessageBox::Show("Error loading project: " + ex->Message, "Error",
                MessageBoxButtons::OK, MessageBoxIcon::Error);
        }
    }

    void SaveHtmlExport(String^ filePath) {
        try {
            StringBuilder^ html = gcnew StringBuilder();
            // ... existing HTML export code ...
            File::WriteAllText(filePath, html->ToString());
        }
        catch (Exception^ ex) {
            MessageBox::Show("HTML export error: " + ex->Message, "Error",
                MessageBoxButtons::OK, MessageBoxIcon::Error);
        }
    }

    void LoadProjectFromFile(Object^ sender, EventArgs^ e) {
        OpenFileDialog^ openDialog = gcnew OpenFileDialog();
        openDialog->Filter = "Maltego Project|*.mtg";
        openDialog->Title = "Load Project";

        if (openDialog->ShowDialog() == Windows::Forms::DialogResult::OK) {
            LoadProject(openDialog->FileName);
        }
    }