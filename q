// MainForm.h
#pragma once

#include "GraphElement.h"
#include "GraphNode.h"
#include "GraphEdge.h"
#include "NodePropertiesEditor.h"
#include <msclr/marshal_cppstd.h>

using namespace System;
using namespace System::IO;
using namespace System::Text;
using namespace System::Drawing;
using namespace System::Windows::Forms;
using namespace System::Collections::Generic;
using namespace msclr::interop;

namespace MaltegoClone {

    private ref class DarkColorTable : public ProfessionalColorTable
    {
    public:
        virtual property Color MenuStripGradientBegin {
            Color get() override { return Color::FromArgb(60, 60, 65); }
        }
        // ... (остальные свойства цвета как в предыдущей версии)
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
            save_menu->Click += gcnew EventHandler(this, &MainForm::SaveMenuClick);
            load_menu->Click += gcnew EventHandler(this, &MainForm::LoadMenuClick);
            export_html_menu->Click += gcnew EventHandler(this, &MainForm::ExportHtmlClick);
            import_html_menu->Click += gcnew EventHandler(this, &MainForm::ImportHtmlClick);
        }

    private:
        // ... (остальные поля как ранее)

        // НОВЫЕ МЕТОДЫ ДЛЯ СОХРАНЕНИЯ/ЗАГРУЗКИ

        void SaveGraph(String^ filePath)
        {
            try
            {
                XmlDocument^ doc = gcnew XmlDocument();
                XmlElement^ root = doc->CreateElement("MaltegoGraph");
                doc->AppendChild(root);

                // Сохраняем узлы
                XmlElement^ nodesElement = doc->CreateElement("Nodes");
                for each (GraphElement ^ node in graph_elements)
                {
                    XmlElement^ nodeElement = doc->CreateElement("Node");
                    nodeElement->SetAttribute("Id", node->id.ToString());
                    nodeElement->SetAttribute("Type", node->type.ToString());
                    nodeElement->SetAttribute("Text", node->text);
                    nodeElement->SetAttribute("X", node->location.X.ToString());
                    nodeElement->SetAttribute("Y", node->location.Y.ToString());
                    nodeElement->SetAttribute("Color", node->color.ToArgb().ToString());
                    
                    // Сохраняем свойства
                    XmlElement^ propsElement = doc->CreateElement("Properties");
                    for each (KeyValuePair<String^, String^> pair in node->properties)
                    {
                        XmlElement^ propElement = doc->CreateElement("Property");
                        propElement->SetAttribute("Key", pair.Key);
                        propElement->SetAttribute("Value", pair.Value);
                        propsElement->AppendChild(propElement);
                    }
                    nodeElement->AppendChild(propsElement);
                    
                    nodesElement->AppendChild(nodeElement);
                }
                root->AppendChild(nodesElement);

                // Сохраняем связи
                XmlElement^ edgesElement = doc->CreateElement("Edges");
                for each (GraphEdge ^ edge in edges)
                {
                    XmlElement^ edgeElement = doc->CreateElement("Edge");
                    edgeElement->SetAttribute("SourceId", edge->source->id.ToString());
                    edgeElement->SetAttribute("TargetId", edge->target->id.ToString());
                    edgeElement->SetAttribute("Color", edge->color.ToArgb().ToString());
                    edgesElement->AppendChild(edgeElement);
                }
                root->AppendChild(edgesElement);

                doc->Save(filePath);
                status_label->Text = "Graph saved successfully";
            }
            catch (Exception^ ex)
            {
                MessageBox::Show("Error saving graph: " + ex->Message, "Error",
                    MessageBoxButtons::OK, MessageBoxIcon::Error);
            }
        }

        void LoadGraph(String^ filePath)
        {
            try
            {
                XmlDocument^ doc = gcnew XmlDocument();
                doc->Load(filePath);

                graph_elements->Clear();
                edges->Clear();

                // Загружаем узлы
                XmlNodeList^ nodeList = doc->SelectNodes("/MaltegoGraph/Nodes/Node");
                Dictionary<int, GraphElement^>^ nodeMap = gcnew Dictionary<int, GraphElement^>();

                for each (XmlNode ^ nodeNode in nodeList)
                {
                    GraphNode^ node = gcnew GraphNode();
                    node->id = Int32::Parse(nodeNode->Attributes["Id"]->Value);
                    node->type = (ElementType)Enum::Parse(ElementType::typeid, nodeNode->Attributes["Type"]->Value);
                    node->text = nodeNode->Attributes["Text"]->Value;
                    node->location = Point(
                        Int32::Parse(nodeNode->Attributes["X"]->Value),
                        Int32::Parse(nodeNode->Attributes["Y"]->Value));
                    node->color = Color::FromArgb(Int32::Parse(nodeNode->Attributes["Color"]->Value));

                    // Загружаем свойства
                    XmlNode^ propsNode = nodeNode->SelectSingleNode("Properties");
                    for each (XmlNode ^ propNode in propsNode->SelectNodes("Property"))
                    {
                        String^ key = propNode->Attributes["Key"]->Value;
                        String^ value = propNode->Attributes["Value"]->Value;
                        node->properties->Add(key, value);
                    }

                    graph_elements->Add(node);
                    nodeMap->Add(node->id, node);
                }

                // Загружаем связи
                XmlNodeList^ edgeList = doc->SelectNodes("/MaltegoGraph/Edges/Edge");
                for each (XmlNode ^ edgeNode in edgeList)
                {
                    GraphEdge^ edge = gcnew GraphEdge();
                    int sourceId = Int32::Parse(edgeNode->Attributes["SourceId"]->Value);
                    int targetId = Int32::Parse(edgeNode->Attributes["TargetId"]->Value);
                    edge->source = nodeMap[sourceId];
                    edge->target = nodeMap[targetId];
                    edge->color = Color::FromArgb(Int32::Parse(edgeNode->Attributes["Color"]->Value));
                    edges->Add(edge);
                }

                node_id_counter = nodeMap->Count + 1;
                graph_panel->Invalidate();
                status_label->Text = "Graph loaded successfully";
            }
            catch (Exception^ ex)
            {
                MessageBox::Show("Error loading graph: " + ex->Message, "Error",
                    MessageBoxButtons::OK, MessageBoxIcon::Error);
            }
        }

        void ExportToHtml(String^ filePath)
        {
            try
            {
                StringBuilder^ html = gcnew StringBuilder();
                html->AppendLine("<!DOCTYPE html>");
                html->AppendLine("<html><head>");
                html->AppendLine("<title>Maltego Graph Export</title>");
                html->AppendLine("<style>");
                html->AppendLine("  .node { position: absolute; border: 1px solid #000; padding: 5px; }");
                html->AppendLine("  .edge { position: absolute; height: 2px; background: #000; transform-origin: 0 0; }");
                html->AppendLine("</style>");
                html->AppendLine("</head><body>");

                // Экспорт узлов
                for each (GraphElement ^ node in graph_elements)
                {
                    String^ color = String::Format("#{0:X2}{1:X2}{2:X2}", 
                        node->color.R, node->color.G, node->color.B);
                    
                    html->AppendFormat(
                        "<div class='node' style='left:{0}px;top:{1}px;width:{2}px;height:{3}px;background:{4}'>",
                        node->location.X, node->location.Y, node->size.Width, node->size.Height, color);
                    html->AppendFormat("<strong>{0}</strong>", node->text);
                    
                    if (node->is_expanded)
                    {
                        html->AppendLine("<ul>");
                        for each (KeyValuePair<String^, String^> prop in node->properties)
                        {
                            html->AppendFormat("<li>{0}: {1}</li>", prop.Key, prop.Value);
                        }
                        html->AppendLine("</ul>");
                    }
                    
                    html->AppendLine("</div>");
                }

                // Экспорт связей
                for each (GraphEdge ^ edge in edges)
                {
                    PointF start = edge->source->location;
                    PointF end = edge->target->location;
                    float length = (float)Math::Sqrt(Math::Pow(end.X - start.X, 2) + Math::Pow(end.Y - start.Y, 2));
                    float angle = (float)(Math::Atan2(end.Y - start.Y, end.X - start.X) * 180 / Math::PI);
                    
                    html->AppendFormat(
                        "<div class='edge' style='left:{0}px;top:{1}px;width:{2}px;transform:rotate({3}deg)'></div>",
                        start.X, start.Y, length, angle);
                }

                html->AppendLine("</body></html>");
                File::WriteAllText(filePath, html->ToString());
                status_label->Text = "Exported to HTML successfully";
            }
            catch (Exception^ ex)
            {
                MessageBox::Show("Error exporting to HTML: " + ex->Message, "Error",
                    MessageBoxButtons::OK, MessageBoxIcon::Error);
            }
        }

        // ОБНОВЛЕННЫЕ ОБРАБОТЧИКИ СОБЫТИЙ

        void SaveMenuClick(Object^ sender, EventArgs^ e)
        {
            SaveFileDialog^ dialog = gcnew SaveFileDialog();
            dialog->Filter = "Maltego Files|*.mtg|All Files|*.*";
            if (dialog->ShowDialog() == Windows::Forms::DialogResult::OK)
            {
                SaveGraph(dialog->FileName);
            }
        }

        void LoadMenuClick(Object^ sender, EventArgs^ e)
        {
            OpenFileDialog^ dialog = gcnew OpenFileDialog();
            dialog->Filter = "Maltego Files|*.mtg|All Files|*.*";
            if (dialog->ShowDialog() == Windows::Forms::DialogResult::OK)
            {
                LoadGraph(dialog->FileName);
            }
        }

        void ExportHtmlClick(Object^ sender, EventArgs^ e)
        {
            SaveFileDialog^ dialog = gcnew SaveFileDialog();
            dialog->Filter = "HTML Files|*.html|All Files|*.*";
            if (dialog->ShowDialog() == Windows::Forms::DialogResult::OK)
            {
                ExportToHtml(dialog->FileName);
            }
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