<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Тёмное святилище | [Ваше имя]</title>
    <link rel="stylesheet" href="style.css">
    <link href="https://fonts.googleapis.com/css2?family=Black+Ops+One&family=Cinzel+Decorative:wght@400;700;900&family=MedievalSharp&display=swap" rel="stylesheet">
</head>
<body>
    <audio id="hoverSound" src="sounds/hover.mp3" preload="auto"></audio>
    <audio id="clickSound" src="sounds/click.mp3" preload="auto"></audio>
    <audio id="bgMusic" loop src="sounds/ambient.mp3"></audio>
    
    <div class="blood-drop" style="top: 10%; left: 15%;"></div>
    <div class="blood-drop" style="top: 30%; left: 80%;"></div>
    <div class="blood-drop" style="top: 70%; left: 25%;"></div>
    <div class="blood-drop" style="top: 85%; left: 65%;"></div>
    
    <div class="pentagram"></div>
    
    <div class="container">
        <header class="header">
            <h1 class="title glitch" data-text="ТЁМНОЕ СВЯТИЛИЩЕ">ТЁМНОЕ СВЯТИЛИЩЕ</h1>
            <p class="subtitle">"Тьма - это не отсутствие света, а вечная сущность самой вселенной"</p>
            <button id="musicToggle" class="music-btn">🔊 Включить ритуал</button>
        </header>
        
        <main class="main-content">
            <section class="profile-section">
                <div class="profile-card">
                    <div class="profile-image">
                        <img src="images/profile.jpg" alt="Тёмный аватар">
                        <div class="blood-overlay"></div>
                    </div>
                    <div class="profile-info">
                        <h2>[Ваше имя]</h2>
                        <p class="dark-quote">"Я иду по пути, освещённому пламенем преисподней"</p>
                        <div class="stats">
                            <div class="stat-item">
                                <span class="stat-name">Уровень тьмы:</span>
                                <div class="stat-bar">
                                    <div class="stat-fill" style="width: 87%;"></div>
                                </div>
                            </div>
                            <div class="stat-item">
                                <span class="stat-name">Знание оккультного:</span>
                                <div class="stat-bar">
                                    <div class="stat-fill" style="width: 92%;"></div>
                                </div>
                            </div>
                            <div class="stat-item">
                                <span class="stat-name">Сила экзорцизма:</span>
                                <div class="stat-bar">
                                    <div class="stat-fill" style="width: 78%;"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
            
            <section class="about-section">
                <h2 class="section-title">О ТЁМНОМ ПУТИ</h2>
                <div class="about-content">
                    <p>Я - странник между мирами, исследователь запретных знаний и практикующий древние ритуалы. Моя жизнь - это постоянное стремление к пониманию сущности тьмы и её места в этом мире.</p>
                    <p>С детства меня привлекало то, что другие называют "злом" или "нечистью". Но я знаю - это просто другая сторона реальности, не менее важная, чем свет.</p>
                    <div class="dark-quote">"Когда все ангелы отвернулись, демоны протянули мне руку"</div>
                </div>
            </section>
            
            <section class="interests-section">
                <h2 class="section-title">ИНТЕРЕСЫ И РИТУАЛЫ</h2>
                <div class="interest-grid">
                    <div class="interest-card">
                        <h3>Игры тьмы</h3>
                        <ul>
                            <li>Doom Eternal</li>
                            <li>Hellblade: Senua's Sacrifice</li>
                            <li>Dark Souls серия</li>
                            <li>Bloodborne</li>
                            <li>The Evil Within</li>
                        </ul>
                        <div class="blood-drip"></div>
                    </div>
                    <div class="interest-card">
                        <h3>Оккультные практики</h3>
                        <ul>
                            <li>Экзорцизм</li>
                            <li>Гоетия</li>
                            <li>Чёрная месса</li>
                            <li>Некромантия</li>
                            <li>Создание пентаграмм</li>
                        </ul>
                        <div class="blood-drip"></div>
                    </div>
                    <div class="interest-card">
                        <h3>Музыка преисподней</h3>
                        <ul>
                            <li>Black Metal</li>
                            <li>Doom Metal</li>
                            <li>Dark Ambient</li>
                            <li>Industrial</li>
                            <li>Witch House</li>
                        </ul>
                        <div class="blood-drip"></div>
                    </div>
                    <div class="interest-card">
                        <h3>Литература тьмы</h3>
                        <ul>
                            <li>"Сатанинская Библия"</li>
                            <li>"Necronomicon"</li>
                            <li>Произведения Лавкрафта</li>
                            <li>"Молот ведьм"</li>
                            <li>"Инферно" Данте</li>
                        </ul>
                        <div class="blood-drip"></div>
                    </div>
                </div>
            </section>
            
            <section class="links-section">
                <h2 class="section-title">СВЯЗЬ С ТЁМНЫМИ СИЛАМИ</h2>
                <div class="links-grid">
                    <a href="#" class="social-link" data-sound="hover2.mp3">
                        <img src="icons/discord.png" alt="Discord">
                        <span>Discord</span>
                    </a>
                    <a href="#" class="social-link" data-sound="hover3.mp3">
                        <img src="icons/telegram.png" alt="Telegram">
                        <span>Telegram</span>
                    </a>
                    <a href="#" class="social-link" data-sound="hover4.mp3">
                        <img src="icons/steam.png" alt="Steam">
                        <span>Steam</span>
                    </a>
                    <a href="#" class="social-link" data-sound="hover5.mp3">
                        <img src="icons/twitch.png" alt="Twitch">
                        <span>Twitch</span>
                    </a>
                    <a href="#" class="social-link" data-sound="hover6.mp3">
                        <img src="icons/youtube.png" alt="YouTube">
                        <span>YouTube</span>
                    </a>
                    <a href="#" class="social-link" data-sound="hover7.mp3">
                        <img src="icons/blog.png" alt="Блог">
                        <span>Тёмный блог</span>
                    </a>
                </div>
            </section>
            
            <section class="quotes-section">
                <h2 class="section-title">ЦИТАТЫ ИЗ ГЛУБИН</h2>
                <div class="quote-carousel">
                    <div class="quote active">
                        <p>"Тьма - это мать всего сущего. Из её лона рождаются звёзды, и в её объятиях они умирают."</p>
                        <cite>- Неизвестный демонолог</cite>
                    </div>
                    <div class="quote">
                        <p>"Когда ты смотришь в бездну, бездна смотрит в тебя. Но лишь немногие осмеливаются заглянуть в ответ."</p>
                        <cite>- Фридрих Ницше (адаптировано)</cite>
                    </div>
                    <div class="quote">
                        <p>"Сатана не враг человека, а единственный, кто дал ему знание и свободу."</p>
                        <cite>- Современный люциферианец</cite>
                    </div>
                </div>
            </section>
        </main>
        
        <footer class="footer">
            <p>© 2023 Тёмное Святилище. Все права отданы князю тьмы.</p>
            <p class="disclaimer">Данный сайт является художественной стилизацией и не пропагандирует насилие или незаконную деятельность.</p>
        </footer>
    </div>
    
    <script src="script.js"></script>
</body>
</html>