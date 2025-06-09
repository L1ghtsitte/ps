I'll help you fix these errors in your code. Here are the corrections needed:

1. First, let's fix the missing menu items in MainForm.h:

```cpp
// In the private section of MainForm class, add these menu items:
ToolStripMenuItem^ new_menu;
ToolStripMenuItem^ save_as_menu;
ToolStripMenuItem^ open_menu;

// In InitializeComponent(), add these menu items to the file_menu:
this->new_menu = gcnew ToolStripMenuItem("New Project");
this->save_as_menu = gcnew ToolStripMenuItem("Save Project As");
this->open_menu = gcnew ToolStripMenuItem("Open Project");

this->file_menu->DropDownItems->Add(this->new_menu);
this->file_menu->DropDownItems->Add(this->open_menu);
this->file_menu->DropDownItems->Add(this->save_menu);
this->file_menu->DropDownItems->Add(this->save_as_menu);
this->file_menu->DropDownItems->Add(this->load_menu);
```

2. Fix the GraphElement::SaveToFile() calls:

```cpp
// Change the SaveToFile() calls in MainForm.h to include the project name:
selected_element->SaveToFile(currentProjectName);  // Instead of just SaveToFile()

// And in the CreateNewNode method:
new_node->SaveToFile(currentProjectName);  // Instead of just SaveToFile()
```

3. The delegate initialization error is likely due to mismatched event handlers. Make sure all event handlers have the correct signature. For example:

```cpp
// Change:
this->new_menu->Click += gcnew EventHandler(this, &MainForm::NewProject);
this->save_menu->Click += gcnew EventHandler(this, &MainForm::SaveProject);
this->save_as_menu->Click += gcnew EventHandler(this, &MainForm::SaveProjectAs);
this->open_menu->Click += gcnew EventHandler(this, &MainForm::LoadProject);

// To match the actual method signatures:
void NewProject(Object^ sender, EventArgs^ e);
void SaveProject(Object^ sender, EventArgs^ e);
void SaveProjectAs(Object^ sender, EventArgs^ e);
void LoadProject(Object^ sender, EventArgs^ e);
```

4. Also make sure the GraphElement class has the correct SaveToFile method signature:

```cpp
// In GraphElement.h, make sure you have:
void SaveToFile(String^ projectName);  // Not just SaveToFile()
```

5. For the NodePropertiesEditor, ensure all event handlers are properly connected:

```cpp
// In NodePropertiesEditor.h, check that all event handlers match:
void PropertyGrid_PropertyValueChanged(Object^ sender, PropertyValueChangedEventArgs^ e);
void SaveChanges(Object^ sender, EventArgs^ e);
void CancelChanges(Object^ sender, EventArgs^ e);
void DeleteNode(Object^ sender, EventArgs^ e);
```

These changes should resolve the compilation errors you're seeing. The key issues were:
1. Missing menu item declarations
2. Incorrect method signatures for event handlers
3. Mismatched SaveToFile method calls
4. Proper delegate initialization

Make sure to rebuild the entire solution after making these changes. If you encounter any other specific errors, please let me know and I can provide more targeted fixes.