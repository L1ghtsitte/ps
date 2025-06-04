#pragma once

#include <vector>
#include <map>
#include <string>
#include <fstream>
#include "GraphElement.h"
#include "GraphNode.h"
#include "GraphEdge.h"
#include "IMaltegoModule.h"

namespace MaltegoClone {

    using namespace System;
    using namespace System::ComponentModel;
    using namespace System::Collections;
    using namespace System::Windows::Forms;
    using namespace System::Data;
    using namespace System::Drawing;
    using namespace System::IO;
    using namespace System::Text;

    public ref class MainForm : public Form
    {
    public:
        MainForm(void)
        {
            InitializeComponent();
            InitializeToolbox();
            this->DoubleBuffered = true;
            graphElements = gcnew List<GraphElement^>();
            edges = gcnew List<GraphEdge^>();
            selectedElement = nullptr;
            isDragging = false;
            isDrawingEdge = false;
            tempEdge = nullptr;
            nodeIdCounter = 1;
            
            // Set up drag and drop
            this->toolbox->ItemDrag += gcnew ItemDragEventHandler(this, &MainForm::toolbox_ItemDrag);
            this->graphPanel->DragEnter += gcnew DragEventHandler(this, &MainForm::graphPanel_DragEnter);
            this->graphPanel->DragDrop += gcnew DragEventHandler(this, &MainForm::graphPanel_DragDrop);
            this->graphPanel->MouseDown += gcnew MouseEventHandler(this, &MainForm::graphPanel_MouseDown);
            this->graphPanel->MouseMove += gcnew MouseEventHandler(this, &MainForm::graphPanel_MouseMove);
            this->graphPanel->MouseUp += gcnew MouseEventHandler(this, &MainForm::graphPanel_MouseUp);
            this->graphPanel->Paint += gcnew PaintEventHandler(this, &MainForm::graphPanel_Paint);
            
            // Load modules
            LoadModules();
        }

    protected:
        ~MainForm()
        {
            if (components)
            {
                delete components;
            }
        }

    private:
        System::ComponentModel::Container ^components;
        System::Windows::Forms::Panel^ graphPanel;
        System::Windows::Forms::MenuStrip^ menuStrip;
        System::Windows::Forms::ToolStripMenuItem^ fileToolStripMenuItem;
        System::Windows::Forms::ToolStripMenuItem^ saveToolStripMenuItem;
        System::Windows::Forms::ToolStripMenuItem^ loadToolStripMenuItem;
        System::Windows::Forms::ToolStripMenuItem^ modulesToolStripMenuItem;
        System::Windows::Forms::StatusStrip^ statusStrip;
        System::Windows::Forms::ToolStripStatusLabel^ statusLabel;
        System::Windows::Forms::ListBox^ toolbox;
        System::Windows::Forms::Button^ addCustomElementButton;
        System::Windows::Forms::TextBox^ customElementName;
        System::Windows::Forms::Button^ edgeModeButton;

        List<GraphElement^>^ graphElements;
        List<GraphEdge^>^ edges;
        GraphElement^ selectedElement;
        bool isDragging;
        Point dragOffset;
        bool isDrawingEdge;
        GraphEdge^ tempEdge;
        int nodeIdCounter;
        List<IMaltegoModule^>^ modules;

        void InitializeComponent(void)
        {
            this->graphPanel = gcnew System::Windows::Forms::Panel();
            this->menuStrip = gcnew System::Windows::Forms::MenuStrip();
            this->fileToolStripMenuItem = gcnew System::Windows::Forms::ToolStripMenuItem();
            this->saveToolStripMenuItem = gcnew System::Windows::Forms::ToolStripMenuItem();
            this->loadToolStripMenuItem = gcnew System::Windows::Forms::ToolStripMenuItem();
            this->modulesToolStripMenuItem = gcnew System::Windows::Forms::ToolStripMenuItem();
            this->statusStrip = gcnew System::Windows::Forms::StatusStrip();
            this->statusLabel = gcnew System::Windows::Forms::ToolStripStatusLabel();
            this->toolbox = gcnew System::Windows::Forms::ListBox();
            this->addCustomElementButton = gcnew System::Windows::Forms::Button();
            this->customElementName = gcnew System::Windows::Forms::TextBox();
            this->edgeModeButton = gcnew System::Windows::Forms::Button();
            this->menuStrip->SuspendLayout();
            this->SuspendLayout();
            
            // graphPanel
            this->graphPanel->BackColor = System::Drawing::SystemColors::Window;
            this->graphPanel->Location = System::Drawing::Point(150, 27);
            this->graphPanel->Name = L"graphPanel";
            this->graphPanel->Size = System::Drawing::Size(650, 423);
            this->graphPanel->TabIndex = 0;
            this->graphPanel->AllowDrop = true;
            
            // menuStrip
            this->menuStrip->Items->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(2) {
                this->fileToolStripMenuItem,
                this->modulesToolStripMenuItem
            });
            this->menuStrip->Location = System::Drawing::Point(0, 0);
            this->menuStrip->Name = L"menuStrip";
            this->menuStrip->Size = System::Drawing::Size(800, 24);
            this->menuStrip->TabIndex = 1;
            this->menuStrip->Text = L"menuStrip1";
            
            // fileToolStripMenuItem
            this->fileToolStripMenuItem->DropDownItems->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(2) {
                this->saveToolStripMenuItem,
                this->loadToolStripMenuItem
            });
            this->fileToolStripMenuItem->Name = L"fileToolStripMenuItem";
            this->fileToolStripMenuItem->Size = System::Drawing::Size(37, 20);
            this->fileToolStripMenuItem->Text = L"File";
            
            // saveToolStripMenuItem
            this->saveToolStripMenuItem->Name = L"saveToolStripMenuItem";
            this->saveToolStripMenuItem->Size = System::Drawing::Size(180, 22);
            this->saveToolStripMenuItem->Text = L"Save Graph as HTML";
            this->saveToolStripMenuItem->Click += gcnew System::EventHandler(this, &MainForm::saveToolStripMenuItem_Click);
            
            // loadToolStripMenuItem
            this->loadToolStripMenuItem->Name = L"loadToolStripMenuItem";
            this->loadToolStripMenuItem->Size = System::Drawing::Size(180, 22);
            this->loadToolStripMenuItem->Text = L"Load Graph from HTML";
            this->loadToolStripMenuItem->Click += gcnew System::EventHandler(this, &MainForm::loadToolStripMenuItem_Click);
            
            // modulesToolStripMenuItem
            this->modulesToolStripMenuItem->Name = L"modulesToolStripMenuItem";
            this->modulesToolStripMenuItem->Size = System::Drawing::Size(65, 20);
            this->modulesToolStripMenuItem->Text = L"Modules";
            
            // statusStrip
            this->statusStrip->Items->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(1) {this->statusLabel});
            this->statusStrip->Location = System::Drawing::Point(0, 450);
            this->statusStrip->Name = L"statusStrip";
            this->statusStrip->Size = System::Drawing::Size(800, 22);
            this->statusStrip->TabIndex = 2;
            this->statusStrip->Text = L"statusStrip1";
            
            // statusLabel
            this->statusLabel->Name = L"statusLabel";
            this->statusLabel->Size = System::Drawing::Size(39, 17);
            this->statusLabel->Text = L"Ready";
            
            // toolbox
            this->toolbox->FormattingEnabled = true;
            this->toolbox->Location = System::Drawing::Point(0, 27);
            this->toolbox->Name = L"toolbox";
            this->toolbox->Size = System::Drawing::Size(150, 355);
            this->toolbox->TabIndex = 3;
            this->toolbox->AllowDrop = true;
            
            // addCustomElementButton
            this->addCustomElementButton->Location = System::Drawing::Point(0, 388);
            this->addCustomElementButton->Name = L"addCustomElementButton";
            this->addCustomElementButton->Size = System::Drawing::Size(150, 23);
            this->addCustomElementButton->TabIndex = 4;
            this->addCustomElementButton->Text = L"Add Custom Element";
            this->addCustomElementButton->Click += gcnew System::EventHandler(this, &MainForm::addCustomElementButton_Click);
            
            // customElementName
            this->customElementName->Location = System::Drawing::Point(0, 415);
            this->customElementName->Name = L"customElementName";
            this->customElementName->Size = System::Drawing::Size(150, 20);
            this->customElementName->TabIndex = 5;
            
            // edgeModeButton
            this->edgeModeButton->Location = System::Drawing::Point(0, 440);
            this->edgeModeButton->Name = L"edgeModeButton";
            this->edgeModeButton->Size = System::Drawing::Size(150, 23);
            this->edgeModeButton->TabIndex = 6;
            this->edgeModeButton->Text = L"Edge Mode (Off)";
            this->edgeModeButton->Click += gcnew System::EventHandler(this, &MainForm::edgeModeButton_Click);
            
            // MainForm
            this->AutoScaleDimensions = System::Drawing::SizeF(6, 13);
            this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
            this->ClientSize = System::Drawing::Size(800, 472);
            this->Controls->Add(this->edgeModeButton);
            this->Controls->Add(this->customElementName);
            this->Controls->Add(this->addCustomElementButton);
            this->Controls->Add(this->toolbox);
            this->Controls->Add(this->statusStrip);
            this->Controls->Add(this->graphPanel);
            this->Controls->Add(this->menuStrip);
            this->MainMenuStrip = this->menuStrip;
            this->Name = L"MainForm";
            this->Text = L"Maltego-like Graph Editor";
            this->menuStrip->ResumeLayout(false);
            this->menuStrip->PerformLayout();
            this->ResumeLayout(false);
            this->PerformLayout();
        }

        void InitializeToolbox()
        {
            // Add default element types
            toolbox->Items->Add("Person");
            toolbox->Items->Add("Organization");
            toolbox->Items->Add("Website");
            toolbox->Items->Add("IP Address");
            toolbox->Items->Add("Email");
            toolbox->Items->Add("Document");
        }

        void LoadModules()
        {
            modules = gcnew List<IMaltegoModule^>();
            // In a real implementation, this would load DLLs
            // For now we'll just add a sample module
            // modules->Add(gcnew SampleModule());
            
            // Add module menu items
            for each (IMaltegoModule^ module in modules)
            {
                ToolStripMenuItem^ item = gcnew ToolStripMenuItem(module->GetModuleName());
                item->Click += gcnew EventHandler(this, &MainForm::ModuleMenuItem_Click);
                modulesToolStripMenuItem->DropDownItems->Add(item);
            }
            
            statusLabel->Text = "Loaded " + modules->Count + " modules";
        }

        void ModuleMenuItem_Click(Object^ sender, EventArgs^ e)
        {
            ToolStripMenuItem^ item = (ToolStripMenuItem^)sender;
            String^ moduleName = item->Text;
            
            for each (IMaltegoModule^ module in modules)
            {
                if (module->GetModuleName() == moduleName)
                {
                    module->Execute(this->graphPanel);
                    break;
                }
            }
        }

        void toolbox_ItemDrag(Object^ sender, ItemDragEventArgs^ e)
        {
            if (e->Item != nullptr)
            {
                DoDragDrop(e->Item, DragDropEffects::Copy);
            }
        }

        void graphPanel_DragEnter(Object^ sender, DragEventArgs^ e)
        {
            if (e->Data->GetDataPresent("System.String"))
            {
                e->Effect = DragDropEffects::Copy;
            }
        }

        void graphPanel_DragDrop(Object^ sender, DragEventArgs^ e)
        {
            if (e->Data->GetDataPresent("System.String"))
            {
                String^ elementType = (String^)e->Data->GetData("System.String");
                Point dropLocation = graphPanel->PointToClient(Point(e->X, e->Y));
                
                GraphNode^ newNode = gcnew GraphNode();
                newNode->Id = nodeIdCounter++;
                newNode->Type = elementType;
                newNode->Text = elementType + " " + newNode->Id;
                newNode->Location = dropLocation;
                newNode->Size = System::Drawing::Size(100, 40);
                newNode->Color = GetColorForType(elementType);
                
                graphElements->Add(newNode);
                graphPanel->Invalidate();
            }
        }

        Color GetColorForType(String^ type)
        {
            if (type == "Person") return Color::LightBlue;
            if (type == "Organization") return Color::LightGreen;
            if (type == "Website") return Color::LightPink;
            if (type == "IP Address") return Color::LightSalmon;
            if (type == "Email") return Color::LightGoldenrodYellow;
            if (type == "Document") return Color::LightGray;
            return Color::White;
        }

        void graphPanel_MouseDown(Object^ sender, MouseEventArgs^ e)
        {
            if (isDrawingEdge)
            {
                // Start drawing an edge
                selectedElement = FindElementAtPoint(e->Location);
                if (selectedElement != nullptr)
                {
                    tempEdge = gcnew GraphEdge();
                    tempEdge->Source = selectedElement;
                    tempEdge->StartPoint = GetElementConnectionPoint(selectedElement, e->Location);
                    tempEdge->EndPoint = e->Location;
                }
            }
            else
            {
                // Select element for moving
                selectedElement = FindElementAtPoint(e->Location);
                if (selectedElement != nullptr)
                {
                    isDragging = true;
                    dragOffset = Point(e->X - selectedElement->Location.X, 
                                      e->Y - selectedElement->Location.Y);
                }
            }
        }

        void graphPanel_MouseMove(Object^ sender, MouseEventArgs^ e)
        {
            if (isDragging && selectedElement != nullptr)
            {
                selectedElement->Location = Point(e->X - dragOffset.X, e->Y - dragOffset.Y);
                graphPanel->Invalidate();
            }
            else if (isDrawingEdge && tempEdge != nullptr)
            {
                tempEdge->EndPoint = e->Location;
                graphPanel->Invalidate();
            }
        }

        void graphPanel_MouseUp(Object^ sender, MouseEventArgs^ e)
        {
            if (isDrawingEdge && tempEdge != nullptr && selectedElement != nullptr)
            {
                GraphElement^ targetElement = FindElementAtPoint(e->Location);
                if (targetElement != nullptr && targetElement != tempEdge->Source)
                {
                    tempEdge->Target = targetElement;
                    tempEdge->EndPoint = GetElementConnectionPoint(targetElement, e->Location);
                    edges->Add(tempEdge);
                }
                tempEdge = nullptr;
                graphPanel->Invalidate();
            }
            
            isDragging = false;
            selectedElement = nullptr;
        }

        GraphElement^ FindElementAtPoint(Point point)
        {
            for (int i = graphElements->Count - 1; i >= 0; i--)
            {
                if (graphElements[i]->Bounds.Contains(point))
                {
                    return graphElements[i];
                }
            }
            return nullptr;
        }

        Point GetElementConnectionPoint(GraphElement^ element, Point referencePoint)
        {
            Rectangle bounds = element->Bounds;
            Point center = Point(bounds.X + bounds.Width / 2, bounds.Y + bounds.Height / 2);
            
            // Simple implementation - connect to nearest edge
            if (Math::Abs(referencePoint.X - center.X) > Math::Abs(referencePoint.Y - center.Y))
            {
                return Point(
                    referencePoint.X < center.X ? bounds.Left : bounds.Right,
                    center.Y
                );
            }
            else
            {
                return Point(
                    center.X,
                    referencePoint.Y < center.Y ? bounds.Top : bounds.Bottom
                );
            }
        }

        void graphPanel_Paint(Object^ sender, PaintEventArgs^ e)
        {
            Graphics^ g = e->Graphics;
            g->SmoothingMode = System::Drawing::Drawing2D::SmoothingMode::AntiAlias;
            
            // Draw edges first (under nodes)
            for each (GraphEdge^ edge in edges)
            {
                edge->Draw(g);
            }
            
            // Draw temporary edge if in edge mode
            if (tempEdge != nullptr)
            {
                tempEdge->Draw(g);
            }
            
            // Draw elements
            for each (GraphElement^ element in graphElements)
            {
                element->Draw(g);
            }
        }

        void addCustomElementButton_Click(Object^ sender, EventArgs^ e)
        {
            if (!String::IsNullOrEmpty(customElementName->Text))
            {
                toolbox->Items->Add(customElementName->Text);
                customElementName->Text = "";
            }
        }

        void edgeModeButton_Click(Object^ sender, EventArgs^ e)
        {
            isDrawingEdge = !isDrawingEdge;
            edgeModeButton->Text = "Edge Mode " + (isDrawingEdge ? "(On)" : "(Off)");
        }

        String^ ColorToHtml(Color color)
        {
            return String::Format("#{0:X2}{1:X2}{2:X2}", color.R, color.G, color.B);
        }

        void saveToolStripMenuItem_Click(Object^ sender, EventArgs^ e)
        {
            SaveFileDialog^ saveDialog = gcnew SaveFileDialog();
            saveDialog->Filter = "HTML Files|*.html|All Files|*.*";
            saveDialog->Title = "Save Graph as HTML";
            
            if (saveDialog->ShowDialog() == System::Windows::Forms::DialogResult::OK)
            {
                try
                {
                    StringBuilder^ htmlBuilder = gcnew StringBuilder();
                    
                    // HTML header
                    htmlBuilder->AppendLine("<!DOCTYPE html>");
                    htmlBuilder->AppendLine("<html>");
                    htmlBuilder->AppendLine("<head>");
                    htmlBuilder->AppendLine("<title>Graph Export</title>");
                    htmlBuilder->AppendLine("<style>");
                    htmlBuilder->AppendLine("  .node { position: absolute; border: 2px solid black; padding: 5px; text-align: center; }");
                    htmlBuilder->AppendLine("  .edge { position: absolute; height: 2px; background-color: black; transform-origin: 0 0; }");
                    htmlBuilder->AppendLine("  .arrow { position: absolute; width: 0; height: 0; border-style: solid; }");
                    htmlBuilder->AppendLine("</style>");
                    htmlBuilder->AppendLine("</head>");
                    htmlBuilder->AppendLine("<body>");
                    
                    // Save nodes
                    for each (GraphElement^ element in graphElements)
                    {
                        htmlBuilder->AppendLine(String::Format(
                            "<div class=\"node\" style=\"left:{0}px; top:{1}px; width:{2}px; height:{3}px; background-color:{4};\">{5}</div>",
                            element->Location.X,
                            element->Location.Y,
                            element->Size.Width,
                            element->Size.Height,
                            ColorToHtml(element->Color),
                            element->Text
                        ));
                    }
                    
                    // Save edges
                    for each (GraphEdge^ edge in edges)
                    {
                        // Calculate edge properties
                        int x1 = edge->StartPoint.X;
                        int y1 = edge->StartPoint.Y;
                        int x2 = edge->EndPoint.X;
                        int y2 = edge->EndPoint.Y;
                        
                        double length = Math::Sqrt(Math::Pow(x2 - x1, 2) + Math::Pow(y2 - y1, 2));
                        double angle = Math::Atan2(y2 - y1, x2 - x1) * 180 / Math::PI;
                        
                        // Edge line
                        htmlBuilder->AppendLine(String::Format(
                            "<div class=\"edge\" style=\"left:{0}px; top:{1}px; width:{2}px; transform: rotate({3}deg);\"></div>",
                            x1, y1, length, angle
                        ));
                        
                        // Arrowhead
                        htmlBuilder->AppendLine(String::Format(
                            "<div class=\"arrow\" style=\"left:{0}px; top:{1}px; border-width:5px 0 5px 10px; border-color:transparent transparent transparent black; transform: translate(-10px, -5px) rotate({2}deg);\"></div>",
                            x2, y2, angle
                        ));
                    }
                    
                    htmlBuilder->AppendLine("</body>");
                    htmlBuilder->AppendLine("</html>");
                    
                    // Write to file
                    File::WriteAllText(saveDialog->FileName, htmlBuilder->ToString());
                    
                    statusLabel->Text = "Graph saved as HTML successfully";
                }
                catch (Exception^ ex)
                {
                    MessageBox::Show("Error saving file: " + ex->Message, "Error", 
                                    MessageBoxButtons::OK, MessageBoxIcon::Error);
                }
            }
        }

        void loadToolStripMenuItem_Click(Object^ sender, EventArgs^ e)
        {
            OpenFileDialog^ openDialog = gcnew OpenFileDialog();
            openDialog->Filter = "HTML Files|*.html|All Files|*.*";
            openDialog->Title = "Load Graph from HTML";
            
            if (openDialog->ShowDialog() == System::Windows::Forms::DialogResult::OK)
            {
                try
                {
                    // HTML loading would be more complex in reality
                    // This is a simplified version that just clears the current graph
                    // since parsing HTML layout would require a full HTML parser
                    
                    graphElements->Clear();
                    edges->Clear();
                    nodeIdCounter = 1;
                    graphPanel->Invalidate();
                    
                    statusLabel->Text = "Graph cleared (HTML loading not fully implemented)";
                    MessageBox::Show("Loading from HTML is not fully implemented in this example. " +
                                    "In a complete implementation, this would parse the HTML and " +
                                    "recreate all nodes and edges.", "Information");
                }
                catch (Exception^ ex)
                {
                    MessageBox::Show("Error loading file: " + ex->Message, "Error", 
                                    MessageBoxButtons::OK, MessageBoxIcon::Error);
                }
            }
        }
    };
}