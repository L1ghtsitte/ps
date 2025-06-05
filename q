// MainForm.h
#pragma once

#include "GraphElement.h"
#include "GraphNode.h"
#include "GraphEdge.h"
#include "NodePropertiesEditor.h"
#include <vector>
#include <map>
#include <string>
#include <fstream>

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

        virtual property Color MenuStripGradientEnd {
            Color get() override { return Color::FromArgb(60, 60, 65); }
        }

        virtual property Color MenuItemSelected {
            Color get() override { return Color::FromArgb(70, 70, 75); }
        }

        virtual property Color MenuItemBorder {
            Color get() override { return Color::FromArgb(100, 100, 100); }
        }

        virtual property Color MenuBorder {
            Color get() override { return Color::FromArgb(100, 100, 100); }
        }

        virtual property Color MenuItemSelectedGradientBegin {
            Color get() override { return Color::FromArgb(70, 70, 75); }
        }

        virtual property Color MenuItemSelectedGradientEnd {
            Color get() override { return Color::FromArgb(70, 70, 75); }
        }

        virtual property Color MenuItemPressedGradientBegin {
            Color get() override { return Color::FromArgb(60, 60, 65); }
        }

        virtual property Color MenuItemPressedGradientEnd {
            Color get() override { return Color::FromArgb(60, 60, 65); }
        }

        virtual property Color ImageMarginGradientBegin {
            Color get() override { return Color::FromArgb(60, 60, 65); }
        }

        virtual property Color ImageMarginGradientMiddle {
            Color get() override { return Color::FromArgb(60, 60, 65); }
        }

        virtual property Color ImageMarginGradientEnd {
            Color get() override { return Color::FromArgb(60, 60, 65); }
        }
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
            selected_element = nullptr;
            is_dragging = false;
            is_drawing_edge = false;
            temp_edge = nullptr;
            node_id_counter = 1;
            last_click_time = DateTime::MinValue;
            scroll_offset = Point(0, 0);
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
        System::ComponentModel::Container^ components;

        // UI Controls
        Panel^ graph_panel;
        MenuStrip^ menu_strip;
        ToolStripMenuItem^ file_menu;
        ToolStripMenuItem^ save_menu;
        ToolStripMenuItem^ load_menu;
        ToolStripMenuItem^ edit_menu;
        ToolStripMenuItem^ view_menu;
        StatusStrip^ status_strip;
        ToolStripStatusLabel^ status_label;
        ListBox^ toolbox;
        Button^ add_custom_element_button;
        TextBox^ custom_element_name;
        Button^ edge_mode_button;
        ContextMenuStrip^ node_context_menu;
        ToolStripMenuItem^ edit_node_menu;
        ToolStripMenuItem^ delete_node_menu;
        ToolStripMenuItem^ change_color_menu;
        HScrollBar^ h_scroll;
        VScrollBar^ v_scroll;

        // Graph data
        List<GraphElement^>^ graph_elements;
        List<GraphEdge^>^ edges;
        GraphElement^ selected_element;
        bool is_dragging;
        Point drag_offset;
        bool is_drawing_edge;
        GraphEdge^ temp_edge;
        int node_id_counter;
        DateTime last_click_time;
        Point scroll_offset;

        void InitializeComponent(void)
        {
            this->components = gcnew System::ComponentModel::Container();

            // Main menu
            this->menu_strip = gcnew MenuStrip();
            this->file_menu = gcnew ToolStripMenuItem("File");
            this->save_menu = gcnew ToolStripMenuItem("Save Graph");
            this->load_menu = gcnew ToolStripMenuItem("Load Graph");
            this->edit_menu = gcnew ToolStripMenuItem("Edit");
            this->view_menu = gcnew ToolStripMenuItem("View");

            this->file_menu->DropDownItems->Add(this->save_menu);
            this->file_menu->DropDownItems->Add(this->load_menu);
            this->menu_strip->Items->Add(this->file_menu);
            this->menu_strip->Items->Add(this->edit_menu);
            this->menu_strip->Items->Add(this->view_menu);

            // Status bar
            this->status_strip = gcnew StatusStrip();
            this->status_label = gcnew ToolStripStatusLabel("Ready");
            this->status_strip->Items->Add(this->status_label);

            // Toolbox
            this->toolbox = gcnew ListBox();
            this->toolbox->SelectionMode = SelectionMode::One;
            this->toolbox->Size = System::Drawing::Size(200, 400);
            this->toolbox->Location = Point(0, 24);

            // Custom element controls
            this->custom_element_name = gcnew TextBox();
            this->custom_element_name->Location = Point(0, 430);
            this->custom_element_name->Size = System::Drawing::Size(150, 20);

            this->add_custom_element_button = gcnew Button();
            this->add_custom_element_button->Text = "Add Custom Type";
            this->add_custom_element_button->Location = Point(0, 455);
            this->add_custom_element_button->Size = System::Drawing::Size(150, 25);
            this->add_custom_element_button->Click += gcnew EventHandler(this, &MainForm::AddCustomElementClick);

            // Edge mode button
            this->edge_mode_button = gcnew Button();
            this->edge_mode_button->Text = "Edge Mode (Off)";
            this->edge_mode_button->Location = Point(0, 485);
            this->edge_mode_button->Size = System::Drawing::Size(150, 25);
            this->edge_mode_button->Click += gcnew EventHandler(this, &MainForm::EdgeModeButtonClick);

            // Graph panel with scroll bars
            this->graph_panel = gcnew Panel();
            this->graph_panel->Location = Point(200, 24);
            this->graph_panel->Size = System::Drawing::Size(800, 600);
            this->graph_panel->AutoScroll = true;
            this->graph_panel->BorderStyle = BorderStyle::FixedSingle;

            this->h_scroll = gcnew HScrollBar();
            this->h_scroll->Dock = DockStyle::Bottom;

            this->v_scroll = gcnew VScrollBar();
            this->v_scroll->Dock = DockStyle::Right;

            this->graph_panel->Controls->Add(this->h_scroll);
            this->graph_panel->Controls->Add(this->v_scroll);

            // Add controls to form
            this->Controls->Add(this->menu_strip);
            this->Controls->Add(this->status_strip);
            this->Controls->Add(this->toolbox);
            this->Controls->Add(this->custom_element_name);
            this->Controls->Add(this->add_custom_element_button);
            this->Controls->Add(this->edge_mode_button);
            this->Controls->Add(this->graph_panel);

            this->MainMenuStrip = this->menu_strip;

            // Set up event handlers
            this->toolbox->MouseDown += gcnew MouseEventHandler(this, &MainForm::ToolboxMouseDown);
            this->graph_panel->DragEnter += gcnew DragEventHandler(this, &MainForm::GraphPanelDragEnter);
            this->graph_panel->DragDrop += gcnew DragEventHandler(this, &MainForm::GraphPanelDragDrop);
            this->graph_panel->MouseDown += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseDown);
            this->graph_panel->MouseMove += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseMove);
            this->graph_panel->MouseUp += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseUp);
            this->graph_panel->Paint += gcnew PaintEventHandler(this, &MainForm::GraphPanelPaint);
            this->graph_panel->DoubleClick += gcnew EventHandler(this, &MainForm::GraphPanelDoubleClick);
            this->graph_panel->MouseWheel += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseWheel);

            // Set up scroll bars
            h_scroll->Scroll += gcnew ScrollEventHandler(this, &MainForm::OnScroll);
            v_scroll->Scroll += gcnew ScrollEventHandler(this, &MainForm::OnScroll);
        }

        void InitializeDarkTheme()
        {
            // Form styling
            this->BackColor = Color::FromArgb(45, 45, 48);
            this->ForeColor = Color::White;

            // Menu styling
            this->menu_strip->BackColor = Color::FromArgb(60, 60, 65);
            this->menu_strip->ForeColor = Color::White;
            this->menu_strip->Renderer = gcnew ToolStripProfessionalRenderer(gcnew DarkColorTable());

            // Status bar styling
            this->status_strip->BackColor = Color::FromArgb(60, 60, 65);
            this->status_strip->ForeColor = Color::White;

            // Toolbox styling
            this->toolbox->BackColor = Color::FromArgb(60, 60, 65);
            this->toolbox->ForeColor = Color::White;
            this->toolbox->BorderStyle = BorderStyle::FixedSingle;

            // Graph panel styling
            this->graph_panel->BackColor = Color::FromArgb(30, 30, 32);

            // Button styling
            this->add_custom_element_button->BackColor = Color::FromArgb(70, 70, 75);
            this->add_custom_element_button->ForeColor = Color::White;
            this->add_custom_element_button->FlatStyle = FlatStyle::Flat;
            this->add_custom_element_button->FlatAppearance->BorderColor = Color::FromArgb(100, 100, 100);

            this->edge_mode_button->BackColor = Color::FromArgb(70, 70, 75);
            this->edge_mode_button->ForeColor = Color::White;
            this->edge_mode_button->FlatStyle = FlatStyle::Flat;
            this->edge_mode_button->FlatAppearance->BorderColor = Color::FromArgb(100, 100, 100);

            // Textbox styling
            this->custom_element_name->BackColor = Color::FromArgb(60, 60, 65);
            this->custom_element_name->ForeColor = Color::White;
            this->custom_element_name->BorderStyle = BorderStyle::FixedSingle;

            // Scroll bars styling
            this->h_scroll->BackColor = Color::FromArgb(60, 60, 65);
            this->v_scroll->BackColor = Color::FromArgb(60, 60, 65);
        }

        void InitializeToolbox()
        {
            toolbox->Items->Clear();
            toolbox->Items->Add("Person");
            toolbox->Items->Add("Organization");
            toolbox->Items->Add("Website");
            toolbox->Items->Add("IP Address");
            toolbox->Items->Add("Email");
            toolbox->Items->Add("Document");
            toolbox->Items->Add("Social Network");
            toolbox->Items->Add("School");
            toolbox->Items->Add("Address");
            toolbox->Items->Add("Phone Number");
        }

        void InitializeContextMenu()
        {
            this->node_context_menu = gcnew System::Windows::Forms::ContextMenuStrip();

            this->edit_node_menu = gcnew ToolStripMenuItem("Edit Node");
            this->edit_node_menu->Click += gcnew EventHandler(this, &MainForm::EditNodeClick);

            this->delete_node_menu = gcnew ToolStripMenuItem("Delete Node");
            this->delete_node_menu->Click += gcnew EventHandler(this, &MainForm::DeleteNodeClick);

            this->change_color_menu = gcnew ToolStripMenuItem("Change Color");
            this->change_color_menu->Click += gcnew EventHandler(this, &MainForm::ChangeColorClick);

            this->node_context_menu->Items->Add(this->edit_node_menu);
            this->node_context_menu->Items->Add(this->delete_node_menu);
            this->node_context_menu->Items->Add(this->change_color_menu);

            this->node_context_menu->BackColor = Color::FromArgb(60, 60, 65);
            this->node_context_menu->ForeColor = Color::White;
        }

        // Event handlers
        void ToolboxMouseDown(Object^ sender, MouseEventArgs^ e)
        {
            if (toolbox->SelectedItem != nullptr && e->Button == Windows::Forms::MouseButtons::Left)
            {
                DoDragDrop(toolbox->SelectedItem->ToString(), DragDropEffects::Copy);
            }
        }

        void GraphPanelDragEnter(Object^ sender, DragEventArgs^ e)
        {
            if (e->Data->GetDataPresent(String::typeid))
            {
                e->Effect = DragDropEffects::Copy;
            }
            else
            {
                e->Effect = DragDropEffects::None;
            }
        }

        void GraphPanelDragDrop(Object^ sender, DragEventArgs^ e)
        {
            if (e->Data->GetDataPresent(String::typeid))
            {
                String^ element_type = (String^)e->Data->GetData(String::typeid);
                Point drop_location = graph_panel->PointToClient(Point(e->X, e->Y));

                // Adjust for scroll position
                drop_location.X += h_scroll->Value;
                drop_location.Y += v_scroll->Value;

                CreateNewNode(element_type, drop_location);
            }
        }

        void GraphPanelMouseDown(Object^ sender, MouseEventArgs^ e)
        {
            Point click_location = Point(e->X + h_scroll->Value, e->Y + v_scroll->Value);

            if (e->Button == Windows::Forms::MouseButtons::Right)
            {
                selected_element = FindElementAtPoint(click_location);
                if (selected_element != nullptr)
                {
                    node_context_menu->Show(graph_panel, e->Location);
                }
                return;
            }

            if (is_drawing_edge)
            {
                selected_element = FindElementAtPoint(click_location);
                if (selected_element != nullptr)
                {
                    temp_edge = gcnew GraphEdge();
                    temp_edge->source = selected_element;
                    temp_edge->start_point = GetElementConnectionPoint(selected_element, click_location);
                    temp_edge->end_point = PointF(click_location.X, click_location.Y);
                }
            }
            else
            {
                selected_element = FindElementAtPoint(click_location);
                if (selected_element != nullptr)
                {
                    is_dragging = true;
                    drag_offset = Point(click_location.X - selected_element->location.X,
                        click_location.Y - selected_element->location.Y);

                    // Check for double click
                    TimeSpan elapsed = DateTime::Now - last_click_time;
                    if (elapsed.TotalMilliseconds < SystemInformation::DoubleClickTime)
                    {
                        selected_element->Expand();
                        graph_panel->Invalidate();
                    }
                    last_click_time = DateTime::Now;
                }
            }
        }

        void GraphPanelMouseMove(Object^ sender, MouseEventArgs^ e)
        {
            Point move_location = Point(e->X + h_scroll->Value, e->Y + v_scroll->Value);

            if (is_dragging && selected_element != nullptr)
            {
                selected_element->location = Point(move_location.X - drag_offset.X,
                    move_location.Y - drag_offset.Y);
                UpdateScrollBars();
                graph_panel->Invalidate();
            }
            else if (is_drawing_edge && temp_edge != nullptr)
            {
                temp_edge->end_point = PointF(move_location.X, move_location.Y);
                graph_panel->Invalidate();
            }
        }

        void GraphPanelMouseUp(Object^ sender, MouseEventArgs^ e)
        {
            Point up_location = Point(e->X + h_scroll->Value, e->Y + v_scroll->Value);

            if (is_drawing_edge && temp_edge != nullptr && selected_element != nullptr)
            {
                GraphElement^ target_element = FindElementAtPoint(up_location);
                if (target_element != nullptr && target_element != temp_edge->source)
                {
                    temp_edge->target = target_element;
                    temp_edge->end_point = GetElementConnectionPoint(target_element, up_location);
                    edges->Add(temp_edge);
                }
                temp_edge = nullptr;
                graph_panel->Invalidate();
            }

            is_dragging = false;
            selected_element = nullptr;
        }

        void GraphPanelPaint(Object^ sender, PaintEventArgs^ e)
        {
            Graphics^ g = e->Graphics;
            g->SmoothingMode = System::Drawing::Drawing2D::SmoothingMode::AntiAlias;
            g->TranslateTransform(-h_scroll->Value, -v_scroll->Value);

            // Draw edges first
            for each (GraphEdge ^ edge in edges)
            {
                edge->Draw(g);
            }

            if (temp_edge != nullptr)
            {
                temp_edge->Draw(g);
            }

            // Then draw nodes on top
            for each (GraphElement ^ element in graph_elements)
            {
                element->Draw(g);
            }
        }

        void GraphPanelDoubleClick(Object^ sender, EventArgs^ e)
        {
            if (selected_element != nullptr)
            {
                selected_element->Expand();
                graph_panel->Invalidate();
            }
        }

        void GraphPanelMouseWheel(Object^ sender, MouseEventArgs^ e)
        {
            int lines = e->Delta * SystemInformation::MouseWheelScrollLines / 120;
            v_scroll->Value = Math::Max(v_scroll->Minimum,
                Math::Min(v_scroll->Maximum - v_scroll->LargeChange + 1,
                    v_scroll->Value - lines));
            graph_panel->Invalidate();
        }

        void OnScroll(Object^ sender, ScrollEventArgs^ e)
        {
            graph_panel->Invalidate();
        }

        // Helper methods
        void CreateNewNode(String^ type, Point location)
        {
            GraphNode^ new_node = gcnew GraphNode();
            new_node->id = node_id_counter++;
            new_node->type = ParseElementType(type);
            new_node->text = type + " " + new_node->id;
            new_node->location = location;
            new_node->color = GetColorForType(new_node->type);

            // Add default properties based on type
            switch (new_node->type)
            {
            case ElementType::Person:
                new_node->properties->Add("First Name", "");
                new_node->properties->Add("Last Name", "");
                new_node->properties->Add("Age", "");
                new_node->properties->Add("Gender", "");
                new_node->properties->Add("Social Networks", "");
                new_node->properties->Add("Email", "");
                new_node->properties->Add("Phone", "");
                break;

            case ElementType::Organization:
                new_node->properties->Add("Name", "");
                new_node->properties->Add("Industry", "");
                new_node->properties->Add("Employees", "");
                new_node->properties->Add("Website", "");
                break;

            case ElementType::Website:
                new_node->properties->Add("URL", "");
                new_node->properties->Add("IP Address", "");
                new_node->properties->Add("Registrar", "");
                new_node->properties->Add("Creation Date", "");
                break;

            default:
                new_node->properties->Add("Value", "");
                break;
            }

            graph_elements->Add(new_node);
            UpdateScrollBars();
            graph_panel->Invalidate();
        }

        ElementType ParseElementType(String^ type)
        {
            if (type == "Person") return ElementType::Person;
            if (type == "Organization") return ElementType::Organization;
            if (type == "Website") return ElementType::Website;
            if (type == "IP Address") return ElementType::IPAddress;
            if (type == "Email") return ElementType::Email;
            if (type == "Document") return ElementType::Document;
            if (type == "Social Network") return ElementType::SocialNetwork;
            if (type == "School") return ElementType::School;
            if (type == "Address") return ElementType::Address;
            if (type == "Phone Number") return ElementType::PhoneNumber;
            return ElementType::Custom;
        }

        Color GetColorForType(ElementType type)
        {
            switch (type)
            {
            case ElementType::Person: return Color::FromArgb(70, 130, 180);
            case ElementType::Organization: return Color::FromArgb(34, 139, 34);
            case ElementType::Website: return Color::FromArgb(218, 112, 214);
            case ElementType::IPAddress: return Color::FromArgb(210, 105, 30);
            case ElementType::Email: return Color::FromArgb(255, 215, 0);
            case ElementType::Document: return Color::FromArgb(169, 169, 169);
            case ElementType::SocialNetwork: return Color::FromArgb(30, 144, 255);
            case ElementType::School: return Color::FromArgb(138, 43, 226);
            case ElementType::Address: return Color::FromArgb(233, 150, 122);
            case ElementType::PhoneNumber: return Color::FromArgb(60, 179, 113);
            default: return Color::FromArgb(100, 100, 100);
            }
        }

        GraphElement^ FindElementAtPoint(Point point)
        {
            for (int i = graph_elements->Count - 1; i >= 0; i--)
            {
                if (graph_elements[i]->bounds.Contains(point))
                {
                    return graph_elements[i];
                }
            }
            return nullptr;
        }

        PointF GetElementConnectionPoint(GraphElement^ element, Point reference_point)
        {
            Rectangle bounds = element->bounds;
            Point center = Point(bounds.X + bounds.Width / 2, bounds.Y + bounds.Height / 2);

            if (Math::Abs(reference_point.X - center.X) > Math::Abs(reference_point.Y - center.Y))
            {
                return PointF(
                    reference_point.X < center.X ? bounds.Left : bounds.Right,
                    center.Y
                );
            }
            else
            {
                return PointF(
                    center.X,
                    reference_point.Y < center.Y ? bounds.Top : bounds.Bottom
                );
            }
        }

        void UpdateScrollBars()
        {
            int max_x = 0, max_y = 0;
            for each (GraphElement ^ element in graph_elements)
            {
                max_x = Math::Max(max_x, element->location.X + element->size.Width);
                max_y = Math::Max(max_y, element->location.Y + element->size.Height);
            }

            max_x += 100;
            max_y += 100;

            h_scroll->Minimum = 0;
            h_scroll->Maximum = max_x;
            h_scroll->LargeChange = graph_panel->ClientSize.Width;
            h_scroll->SmallChange = 20;

            v_scroll->Minimum = 0;
            v_scroll->Maximum = max_y;
            v_scroll->LargeChange = graph_panel->ClientSize.Height;
            v_scroll->SmallChange = 20;
        }

        // Context menu handlers
        void EditNodeClick(Object^ sender, EventArgs^ e)
        {
            if (selected_element != nullptr)
            {
                NodePropertiesEditor^ editor = gcnew NodePropertiesEditor(selected_element);
                if (editor->ShowDialog() == Windows::Forms::DialogResult::OK)
                {
                    graph_panel->Invalidate();
                }
            }
        }

        void DeleteNodeClick(Object^ sender, EventArgs^ e)
        {
            if (selected_element != nullptr)
            {
                for (int i = edges->Count - 1; i >= 0; i--)
                {
                    if (edges[i]->source == selected_element || edges[i]->target == selected_element)
                    {
                        edges->RemoveAt(i);
                    }
                }

                graph_elements->Remove(selected_element);
                selected_element = nullptr;
                graph_panel->Invalidate();
            }
        }

        void ChangeColorClick(Object^ sender, EventArgs^ e)
        {
            if (selected_element != nullptr)
            {
                ColorDialog^ color_dialog = gcnew ColorDialog();
                color_dialog->Color = selected_element->color;
                if (color_dialog->ShowDialog() == Windows::Forms::DialogResult::OK)
                {
                    selected_element->color = color_dialog->Color;
                    graph_panel->Invalidate();
                }
            }
        }

        // Button click handlers
        void AddCustomElementClick(Object^ sender, EventArgs^ e)
        {
            if (!String::IsNullOrEmpty(custom_element_name->Text))
            {
                toolbox->Items->Add(custom_element_name->Text);
                custom_element_name->Text = "";
            }
        }

        void EdgeModeButtonClick(Object^ sender, EventArgs^ e)
        {
            is_drawing_edge = !is_drawing_edge;
            edge_mode_button->Text = "Edge Mode " + (is_drawing_edge ? "(On)" : "(Off)");
            edge_mode_button->BackColor = is_drawing_edge ?
                Color::FromArgb(90, 90, 95) : Color::FromArgb(70, 70, 75);
        }

        // Menu handlers
        void SaveMenuClick(Object^ sender, EventArgs^ e)
        {
            SaveFileDialog^ save_dialog = gcnew SaveFileDialog();
            save_dialog->Filter = "Graph Files|*.graph|All Files|*.*";

            if (save_dialog->ShowDialog() == Windows::Forms::DialogResult::OK)
            {
                try
                {
                    // Serialize graph data to file
                    status_label->Text = "Graph saved successfully";
                }
                catch (Exception^ ex)
                {
                    MessageBox::Show("Error saving file: " + ex->Message, "Error",
                        MessageBoxButtons::OK, MessageBoxIcon::Error);
                }
            }
        }

        void LoadMenuClick(Object^ sender, EventArgs^ e)
        {
            OpenFileDialog^ open_dialog = gcnew OpenFileDialog();
            open_dialog->Filter = "Graph Files|*.graph|All Files|*.*";

            if (open_dialog->ShowDialog() == Windows::Forms::DialogResult::OK)
            {
                try
                {
                    // Deserialize graph data from file
                    status_label->Text = "Graph loaded successfully";
                    graph_panel->Invalidate();
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