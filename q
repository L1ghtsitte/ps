void GraphPanelMouseDown(Object^ sender, MouseEventArgs^ e) {
    Point clickPoint = Point(e->X + h_scroll->Value, e->Y + v_scroll->Value);
    selected_element = FindElementAtPoint(clickPoint);

    if (selected_element != nullptr) {
        if (e->Button == Windows::Forms::MouseButtons::Left) {
            if (selected_element->HitTestResizeHandle(clickPoint)) {
                selected_element->StartResizing(clickPoint);
            }
            else {
                is_dragging = true;
                drag_offset = Point(clickPoint.X - selected_element->location.X,
                    clickPoint.Y - selected_element->location.Y);
            }
        }
        else if (e->Button == Windows::Forms::MouseButtons::Right) {
            ContextMenuStrip^ contextMenu = gcnew ContextMenuStrip();
            
            ToolStripMenuItem^ deleteItem = gcnew ToolStripMenuItem("Удалить");
            deleteItem->Click += gcnew EventHandler(this, &MainForm::DeleteSelectedElement);
            contextMenu->Items->Add(deleteItem);

            ToolStripMenuItem^ propertiesItem = gcnew ToolStripMenuItem("Свойства");
            propertiesItem->Click += gcnew EventHandler(this, &MainForm::ShowElementProperties);
            contextMenu->Items->Add(propertiesItem);

            contextMenu->Show(graph_panel, e->Location);
        }
    }
    else if (is_drawing_edge && selected_element != nullptr) {
        temp_edge = gcnew GraphEdge();
        temp_edge->source = selected_element;
        temp_edge->start_point = GetElementConnectionPoint(selected_element, clickPoint);
        temp_edge->end_point = clickPoint;
    }

    graph_panel->Invalidate();
}