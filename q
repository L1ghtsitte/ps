void InitializeComponent(void) {
    this->components = gcnew System::ComponentModel::Container();

    // 1. Инициализация всех элементов управления
    this->menu_strip = gcnew MenuStrip();
    this->file_menu = gcnew ToolStripMenuItem("File");
    this->save_menu = gcnew ToolStripMenuItem("Save Graph");
    this->load_menu = gcnew ToolStripMenuItem("Load Graph");
    this->status_strip = gcnew StatusStrip();
    this->status_label = gcnew ToolStripStatusLabel("Ready");
    this->toolbox = gcnew ListBox();
    this->custom_element_name = gcnew TextBox();
    this->add_custom_element_button = gcnew Button();
    this->edge_mode_button = gcnew Button();
    this->graph_panel = gcnew Panel();  // Теперь graph_panel создан
    this->h_scroll = gcnew HScrollBar();
    this->v_scroll = gcnew VScrollBar();

    // 2. Настройка свойств элементов
    this->Text = "Advanced Maltego Clone";
    this->Size = System::Drawing::Size(1200, 800);
    this->StartPosition = FormStartPosition::CenterScreen;
    this->KeyPreview = true;

    // Настройка toolbox
    this->toolbox->SelectionMode = SelectionMode::One;
    this->toolbox->Size = System::Drawing::Size(200, 400);
    this->toolbox->Location = Point(10, 50);

    // Настройка кнопок и полей ввода
    this->custom_element_name->Location = Point(10, 460);
    this->custom_element_name->Size = System::Drawing::Size(180, 20);

    this->add_custom_element_button->Text = "Add Custom Type";
    this->add_custom_element_button->Location = Point(10, 490);
    this->add_custom_element_button->Size = System::Drawing::Size(180, 25);

    this->edge_mode_button->Text = "Edge Mode (Off)";
    this->edge_mode_button->Location = Point(10, 525);
    this->edge_mode_button->Size = System::Drawing::Size(180, 25);

    // Настройка graph_panel и скроллбаров
    this->graph_panel->Location = Point(220, 50);
    this->graph_panel->Size = System::Drawing::Size(950, 700);
    this->graph_panel->AutoScroll = false;
    this->graph_panel->BorderStyle = BorderStyle::FixedSingle;

    this->h_scroll->Dock = DockStyle::Bottom;
    this->v_scroll->Dock = DockStyle::Right;

    // 3. Добавление обработчиков событий (теперь graph_panel не null)
    this->KeyDown += gcnew KeyEventHandler(this, &MainForm::MainForm_KeyDown);
    this->toolbox->MouseDown += gcnew MouseEventHandler(this, &MainForm::ToolboxMouseDown);
    this->graph_panel->MouseDown += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseDown);
    this->graph_panel->MouseMove += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseMove);
    this->graph_panel->MouseUp += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseUp);
    this->graph_panel->Paint += gcnew PaintEventHandler(this, &MainForm::GraphPanelPaint);
    this->graph_panel->DoubleClick += gcnew EventHandler(this, &MainForm::GraphPanelDoubleClick);
    this->graph_panel->MouseWheel += gcnew MouseEventHandler(this, &MainForm::GraphPanelMouseWheel);

    this->add_custom_element_button->Click += gcnew EventHandler(this, &MainForm::AddCustomElementClick);
    this->edge_mode_button->Click += gcnew EventHandler(this, &MainForm::EdgeModeButtonClick);

    // Настройка скроллбаров
    h_scroll->Scroll += gcnew ScrollEventHandler(this, &MainForm::OnScroll);
    v_scroll->Scroll += gcnew ScrollEventHandler(this, &MainForm::OnScroll);

    // 4. Добавление элементов в контейнеры
    this->graph_panel->Controls->Add(this->h_scroll);
    this->graph_panel->Controls->Add(this->v_scroll);
    this->status_strip->Items->Add(this->status_label);

    // 5. Добавление элементов на форму
    this->Controls->Add(this->menu_strip);
    this->Controls->Add(this->status_strip);
    this->Controls->Add(this->toolbox);
    this->Controls->Add(this->custom_element_name);
    this->Controls->Add(this->add_custom_element_button);
    this->Controls->Add(this->edge_mode_button);
    this->Controls->Add(this->graph_panel);

    this->MainMenuStrip = this->menu_strip;
}