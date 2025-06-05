// MainForm.h
#pragma once

#include "GraphElement.h"
#include "GraphNode.h"
#include "GraphEdge.h"
#include "NodePropertiesEditor.h"

using namespace System;
using namespace System::IO;
using namespace System::Text;
using namespace System::Drawing;
using namespace System::Windows::Forms;
using namespace System::Collections::Generic;

namespace MaltegoClone {

    private ref class DarkColorTable : public ProfessionalColorTable
    {
    public:
        virtual property Color MenuStripGradientBegin {
            Color get() override { return Color::FromArgb(60, 60, 65); }
        }
        // ... (остальные свойства цвета)
    };

    public ref class MainForm : public Form
    {
    public:
        MainForm(void)
        {
            InitializeComponent();
            InitializeToolbox();
            InitializeDarkTheme();
            InitializeContextMenu();

            this->DoubleBuffered = true;
            this->AllowDrop = true;
            this->graph_panel->AllowDrop = true;

            graph_elements = gcnew List<GraphElement^>();
            edges = gcnew List<GraphEdge^>();
            node_id_counter = 1;
            
            // Инициализация меню
            export_html_menu->Click += gcnew EventHandler(this, &MainForm::ExportToHtml);
            import_html_menu->Click += gcnew EventHandler(this, &MainForm::ImportFromHtml);
        }

    private:
        // ... (поля как ранее)

        void ExportToHtml(Object^ sender, EventArgs^ e)
        {
            SaveFileDialog^ saveDialog = gcnew SaveFileDialog();
            saveDialog->Filter = "HTML Files|*.html|All Files|*.*";
            saveDialog->Title = "Export Graph to HTML";
            
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
                    html->AppendLine("  </style>");
                    html->AppendLine("</head>");
                    html->AppendLine("<body>");
                    html->AppendLine("  <h1>Maltego Graph Export</h1>");
                    html->AppendLine("  <div class=\"graph-container\" id=\"graph\">");

                    // Export Nodes
                    for each (GraphElement ^ node in graph_elements)
                    {
                        html->AppendFormat("    <div class=\"node\" style=\"left:{0}px;top:{1}px;width:{2}px;min-height:{3}px;background-color:{4};\">",
                            node->location.X, node->location.Y, node->size.Width, node->size.Height, 
                            ColorToHex(node->color));
                        
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

                    // Export Edges
                    for each (GraphEdge ^ edge in edges)
                    {
                        PointF start = edge->source->location;
                        PointF end = edge->target->location;
                        
                        float dx = end.X - start.X;
                        float dy = end.Y - start.Y;
                        float length = (float)Math::Sqrt(dx * dx + dy * dy);
                        float angle = (float)(Math::Atan2(dy, dx) * 180.0 / Math::PI);
                        
                        html->AppendFormat("    <div class=\"edge\" style=\"left:{0}px;top:{1}px;width:{2}px;transform:rotate({3}deg);background-color:{4};\"></div>",
                            start.X, start.Y, length, angle, ColorToHex(edge->color));
                    }

                    // HTML Footer
                    html->AppendLine("  </div>");
                    html->AppendLine("</body>");
                    html->AppendLine("</html>");

                    File::WriteAllText(saveDialog->FileName, html->ToString());
                    MessageBox::Show("Graph successfully exported to HTML!", "Export Complete", 
                        MessageBoxButtons::OK, MessageBoxIcon::Information);
                }
                catch (Exception^ ex)
                {
                    MessageBox::Show("Error exporting to HTML: " + ex->Message, "Export Error", 
                        MessageBoxButtons::OK, MessageBoxIcon::Error);
                }
            }
        }

        void ImportFromHtml(Object^ sender, EventArgs^ e)
        {
            OpenFileDialog^ openDialog = gcnew OpenFileDialog();
            openDialog->Filter = "HTML Files|*.html|All Files|*.*";
            openDialog->Title = "Import Graph from HTML";
            
            if (openDialog->ShowDialog() == Windows::Forms::DialogResult::OK)
            {
                try
                {
                    String^ html = File::ReadAllText(openDialog->FileName);
                    // Здесь должна быть логика парсинга HTML и создания графа
                    // Это сложная задача, требующая полноценного парсера HTML
                    MessageBox::Show("HTML import is not fully implemented yet.", "Info", 
                        MessageBoxButtons::OK, MessageBoxIcon::Information);
                }
                catch (Exception^ ex)
                {
                    MessageBox::Show("Error importing from HTML: " + ex->Message, "Import Error", 
                        MessageBoxButtons::OK, MessageBoxIcon::Error);
                }
            }
        }

        // Helper Methods
        String^ ColorToHex(Color color)
        {
            return String::Format("#{0:X2}{1:X2}{2:X2}", color.R, color.G, color.B);
        }

        String^ EscapeHtml(String^ input)
        {
            if (String::IsNullOrEmpty(input)) return String::Empty;
            return input->Replace("&", "&amp;")
                        ->Replace("<", "&lt;")
                        ->Replace(">", "&gt;")
                        ->Replace("\"", "&quot;")
                        ->Replace("'", "&#39;");
        }

        // ... (остальные методы как ранее)
    };
}

// Точка входа
[STAThread]
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
    Application::EnableVisualStyles();
    Application::SetCompatibleTextRenderingDefault(false);
    Application::Run(gcnew MaltegoClone::MainForm());
    return 0;
}