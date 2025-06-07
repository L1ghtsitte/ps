void InitializeComponent(void) {
    this->components = gcnew System::ComponentModel::Container();

    // Main form setup
    this->Text = "Advanced Maltego Clone";
    this->Size = System::Drawing::Size(1200, 800);
    this->StartPosition = FormStartPosition::CenterScreen;
    this->KeyPreview = true;

    // Initialize controls first
    this->menu_strip = gcnew MenuStrip();
    this->file_menu = gcnew ToolStripMenuItem("File");
    this->save_menu = gcnew ToolStripMenuItem("Save Graph (HTML)");
    this->load_menu = gcnew ToolStripMenuItem("Load Graph (HTML)");
    this->status_strip = gcnew StatusStrip();
    this->status_label = gcnew ToolStripStatusLabel("Ready");
    this->toolbox = gcnew ListBox();
    this->custom_element_name = gcnew TextBox();
    this->add_custom_element_button = gcnew Button();
    this->edge_mode_button = gcnew Button();
    this->graph_panel = gcnew Panel();
    this->h_scroll = gcnew HScrollBar();
    this->v_scroll = gcnew VScrollBar();

    // Menu setup
    this->file_menu->DropDownItems->Add(this->save_menu);
    this->file_menu->DropDownItems->Add(this->load_menu);
    this->menu_strip->Items->Add(this->file_menu);

    // Set control properties
    this->toolbox->SelectionMode = SelectionMode::One;
    this->toolbox->Size = System::Drawing::Size(200, 400);
    this->toolbox->Location = Point(10, 50);

    this->custom_element_name->Location = Point(10, 460);
    this->custom_element_name->Size = System::Drawing::Size(180, 20);

    this->add_custom_element_button->Text = "Add Custom Type";
    this->add_custom_element_button->Location = Point(10, 490);
    this->add_custom_element_button->Size = System::Drawing::Size(180, 25);

    this->edge_mode_button->Text = "Edge Mode (Off)";
    this->edge_mode_button->Location = Point(10, 525);
    this->edge_mode_button->Size = System::Drawing::Size(180, 25);

    this->graph_panel->Location = Point(220, 50);
    this->graph_panel->Size = System::Drawing::Size(950, 700);
    this->graph_panel->AutoScroll = false;
    this->graph_panel->BorderStyle = BorderStyle::FixedSingle;

    this->h_scroll->Dock = DockStyle::Bottom;
    this->v_scroll->Dock = DockStyle::Right;

    // Add event handlers (after controls are initialized)
    this->KeyDown += gcnew KeyEventHandler(this, &MainForm::MainForm_KeyDown);
    this->save_menu->Click += gcnew EventHandler(this, &MainForm::ExportToHtml);
    this->load_menu->Click += gcnew EventHandler(this, &MainForm::ImportFromHtml);
    this->toolbox->MouseDown += gcnew MouseEventHandler(this, &MainForm::ToolboxMouseDown);
    this->graph_panel->MouseDown += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseDown);
    this->graph_panel->MouseMove += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseMove);
    this->graph_panel->MouseUp += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseUp);
    this->graph_panel->Paint += gcnew PaintEventHandler(this, &MainForm::GraphPanelPaint);
    this->graph_panel->DoubleClick += gcnew EventHandler(this, &MainForm::GraphPanelDoubleClick);
    this->graph_panel->MouseWheel += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseWheel);
    this->add_custom_element_button->Click += gcnew EventHandler(this, &MainForm::AddCustomElementClick);
    this->edge_mode_button->Click += gcnew EventHandler(this, &MainForm::EdgeModeButtonClick);

    // Scroll bars
    h_scroll->Scroll += gcnew ScrollEventHandler(this, &MainForm::OnScroll);
    v_scroll->Scroll += gcnew ScrollEventHandler(this, &MainForm::OnScroll);

    // Add controls to containers
    this->graph_panel->Controls->Add(this->h_scroll);
    this->graph_panel->Controls->Add(this->v_scroll);
    this->status_strip->Items->Add(this->status_label);

    // Add controls to form
    this->Controls->Add(this->menu_strip);
    this->Controls->Add(this->status_strip);
    this->Controls->Add(this->toolbox);
    this->Controls->Add(this->custom_element_name);
    this->Controls->Add(this->add_custom_element_button);
    this->Controls->Add(this->edge_mode_button);
    this->Controls->Add(this->graph_panel);

    this->MainMenuStrip = this->menu_strip;
}