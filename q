void editNodeToolStripMenuItem_Click(Object^ sender, EventArgs^ e)
{
    if (selectedElement != nullptr)
    {
        // Create a form to edit node properties
        Form^ editForm = gcnew Form();
        editForm->Text = "Edit " + selectedElement->Type;
        editForm->Width = 400;
        editForm->Height = 500;
        
        PropertyGrid^ propertyGrid = gcnew PropertyGrid();
        propertyGrid->Dock = DockStyle::Fill;
        
        // Create a custom class to hold properties
        ref class NodeProperties
        {
        public:
            property String^ Text;
            
            // Add other properties as needed
            property String^ FirstName;
            property String^ LastName;
            // ... etc
        };
        
        NodeProperties^ nodeProps = gcnew NodeProperties();
        nodeProps->Text = selectedElement->Text;
        
        // Copy existing properties if they exist
        if (selectedElement->Properties != nullptr)
        {
            for each (KeyValuePair<String^, String^>^ pair in selectedElement->Properties)
            {
                // You would need to map these to the appropriate properties
                // This is a simplified example
                if (pair->Key == "First Name") nodeProps->FirstName = pair->Value;
                if (pair->Key == "Last Name") nodeProps->LastName = pair->Value;
                // ... etc
            }
        }
        
        propertyGrid->SelectedObject = nodeProps;
        editForm->Controls->Add(propertyGrid);
        
        Button^ saveButton = gcnew Button();
        saveButton->Text = "Save";
        saveButton->Dock = DockStyle::Bottom;
        saveButton->Click += gcnew EventHandler(this, &MainForm::saveProperties_Click);
        editForm->Controls->Add(saveButton);
        
        editForm->ShowDialog();
    }
}