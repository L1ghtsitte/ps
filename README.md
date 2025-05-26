/* Основные стили */
:root {
    --blood-red: #8a0303;
    --dark-red: #5e0000;
    --black: #0a0a0a;
    --dark-gray: #1a1a1a;
    --gray: #2a2a2a;
    --light-gray: #3a3a3a;
    --white: #e0e0e0;
    --gold: #d4af37;
    --pentagram: #8a0303;
}

@keyframes flicker {
    0%, 19%, 21%, 23%, 25%, 54%, 56%, 100% {
        text-shadow: 
            0 0 5px var(--blood-red),
            0 0 10px var(--blood-red),
            0 0 20px var(--blood-red),
            0 0 40px var(--dark-red),
            0 0 80px var(--dark-red),
            0 0 90px var(--dark-red),
            0 0 100px var(--dark-red),
            0 0 150px var(--dark-red);
    }
    20%, 24%, 55% {        
        text-shadow: none;
    }
}

@keyframes float {
    0%, 100% {
        transform: translateY(0);
    }
    50% {
        transform: translateY(-10px);
    }
}

@keyframes bloodPulse {
    0% {
        opacity: 0.7;
    }
    50% {
        opacity: 0.3;
    }
    100% {
        opacity: 0.7;
    }
}

@keyframes rotate {
    from {
        transform: rotate(0deg);
    }
    to {
        transform: rotate(360deg);
    }
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'MedievalSharp', cursive;
    background-color: var(--black);
    color: var(--white);
    line-height: 1.6;
    overflow-x: hidden;
    position: relative;
    background-image: url('images/dark-texture.jpg');
    background-attachment: fixed;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
    position: relative;
    z-index: 2;
}

/* Кровавые капли */
.blood-drop {
    position: fixed;
    width: 150px;
    height: 150px;
    background-image: url('images/blood-drop.png');
    background-size: contain;
    background-repeat: no-repeat;
    opacity: 0.7;
    z-index: 1;
    animation: bloodPulse 5s infinite;
}

/* Пентаграмма */
.pentagram {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 100vmax;
    height: 100vmax;
    background-image: url('images/pentagram.png');
    background-size: contain;
    background-position: center;
    background-repeat: no-repeat;
    opacity: 0.05;
    z-index: 0;
    animation: rotate 120s linear infinite;
}

/* Шапка */
.header {
    text-align: center;
    padding: 40px 0;
    position: relative;
}

.title {
    font-family: 'Black Ops One', cursive;
    font-size: 4rem;
    color: var(--blood-red);
    margin-bottom: 20px;
    text-transform: uppercase;
    letter-spacing: 5px;
    animation: flicker 8s infinite alternate;
    position: relative;
}

.glitch::before, .glitch::after {
    content: attr(data-text);
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
}

.glitch::before {
    animation: glitch-effect 3s infinite linear alternate-reverse;
    left: 2px;
    text-shadow: -2px 0 #00ffea;
    clip: rect(44px, 450px, 56px, 0);
}

.glitch::after {
    animation: glitch-effect 2s infinite linear alternate-reverse;
    left: -2px;
    text-shadow: -2px 0 #ff00ea;
    clip: rect(44px, 450px, 56px, 0);
}

@keyframes glitch-effect {
    0% {
        clip: rect(31px, 9999px, 94px, 0);
    }
    10% {
        clip: rect(112px, 9999px, 76px, 0);
    }
    20% {
        clip: rect(85px, 9999px, 77px, 0);
    }
    30% {
        clip: rect(27px, 9999px, 97px, 0);
    }
    40% {
        clip: rect(64px, 9999px, 98px, 0);
    }
    50% {
        clip: rect(61px, 9999px, 85px, 0);
    }
    60% {
        clip: rect(99px, 9999px, 114px, 0);
    }
    70% {
        clip: rect(34px, 9999px, 115px, 0);
    }
    80% {
        clip: rect(98px, 9999px, 129px, 0);
    }
    90% {
        clip: rect(43px, 9999px, 96px, 0);
    }
    100% {
        clip: rect(82px, 9999px, 64px, 0);
    }
}

.subtitle {
    font-family: 'Cinzel Decorative', cursive;
    font-size: 1.2rem;
    color: var(--gold);
    margin-bottom: 30px;
    text-shadow: 0 0 5px rgba(212, 175, 55, 0.5);
}

.music-btn {
    background: transparent;
    border: 1px solid var(--blood-red);
    color: var(--white);
    padding: 10px 20px;
    font-family: 'MedievalSharp', cursive;
    font-size: 1rem;
    cursor: pointer;
    transition: all 0.3s ease;
    border-radius: 5px;
    margin-top: 20px;
}

.music-btn:hover {
    background: var(--blood-red);
    text-shadow: 0 0 5px var(--white);
    box-shadow: 0 0 10px var(--blood-red);
}

/* Карточка профиля */
.profile-section {
    margin: 40px 0;
}

.profile-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    background: rgba(10, 10, 10, 0.8);
    border: 1px solid var(--blood-red);
    border-radius: 10px;
    padding: 30px;
    box-shadow: 0 0 20px rgba(138, 3, 3, 0.3);
    position: relative;
    overflow: hidden;
}

.profile-image {
    width: 200px;
    height: 200px;
    border-radius: 50%;
    overflow: hidden;
    border: 3px solid var(--blood-red);
    position: relative;
    margin-bottom: 20px;
}

.profile-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.blood-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-image: url('images/blood-pattern.png');
    background-size: cover;
    opacity: 0.3;
    mix-blend-mode: multiply;
}

.profile-info h2 {
    font-family: 'Cinzel Decorative', cursive;
    font-size: 2rem;
    color: var(--blood-red);
    margin-bottom: 10px;
    text-align: center;
}

.dark-quote {
    font-style: italic;
    color: var(--gold);
    margin: 15px 0;
    text-align: center;
    position: relative;
    padding: 10px;
}

.dark-quote::before, .dark-quote::after {
    content: '"';
    color: var(--blood-red);
    font-size: 1.5rem;
}

.stats {
    width: 100%;
    margin-top: 20px;
}

.stat-item {
    margin-bottom: 15px;
}

.stat-name {
    display: block;
    margin-bottom: 5px;
    color: var(--gold);
}

.stat-bar {
    width: 100%;
    height: 10px;
    background: var(--dark-gray);
    border-radius: 5px;
    overflow: hidden;
}

.stat-fill {
    height: 100%;
    background: linear-gradient(90deg, var(--dark-red), var(--blood-red));
    border-radius: 5px;
    position: relative;
}

.stat-fill::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(90deg, 
        transparent, 
        rgba(255, 255, 255, 0.2), 
        transparent);
    animation: stat-glow 2s infinite;
}

@keyframes stat-glow {
    0% {
        transform: translateX(-100%);
    }
    100% {
        transform: translateX(100%);
    }
}

/* Секции */
.section-title {
    font-family: 'Cinzel Decorative', cursive;
    font-size: 2rem;
    color: var(--blood-red);
    margin: 40px 0 20px;
    text-align: center;
    position: relative;
}

.section-title::after {
    content: '';
    display: block;
    width: 100px;
    height: 2px;
    background: var(--blood-red);
    margin: 10px auto;
    box-shadow: 0 0 10px var(--blood-red);
}

.about-content {
    background: rgba(10, 10, 10, 0.7);
    border: 1px solid var(--blood-red);
    border-radius: 10px;
    padding: 20px;
    margin-bottom: 30px;
    position: relative;
}

.about-content::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-image: url('images/old-paper.png');
    opacity: 0.2;
    z-index: -1;
    border-radius: 10px;
}

/* Карточки интересов */
.interest-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin-bottom: 40px;
}

.interest-card {
    background: rgba(26, 26, 26, 0.8);
    border: 1px solid var(--blood-red);
    border-radius: 10px;
    padding: 20px;
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
}

.interest-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 15px rgba(138, 3, 3, 0.5);
}

.interest-card h3 {
    color: var(--gold);
    margin-bottom: 15px;
    font-family: 'Cinzel Decorative', cursive;
    border-bottom: 1px solid var(--blood-red);
    padding-bottom: 5px;
}

.interest-card ul {
    list-style-type: none;
}

.interest-card li {
    padding: 5px 0;
    position: relative;
    padding-left: 20px;
}

.interest-card li::before {
    content: '✠';
    position: absolute;
    left: 0;
    color: var(--blood-red);
}

.blood-drip {
    position: absolute;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 30px;
    height: 30px;
    background-image: url('images/blood-drip.png');
    background-size: contain;
    background-repeat: no-repeat;
    opacity: 0.7;
}

/* Социальные ссылки */
.links-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 15px;
    margin-bottom: 40px;
}

.social-link {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background: rgba(26, 26, 26, 0.8);
    border: 1px solid var(--blood-red);
    border-radius: 10px;
    padding: 15px;
    text-decoration: none;
    color: var(--white);
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
}

.social-link:hover {
    background: var(--blood-red);
    transform: scale(1.05);
    box-shadow: 0 0 15px var(--blood-red);
}

.social-link img {
    width: 40px;
    height: 40px;
    margin-bottom: 10px;
    filter: drop-shadow(0 0 5px rgba(138, 3, 3, 0.7));
}

.social-link span {
    font-size: 0.9rem;
    text-align: center;
}

/* Карусель цитат */
.quote-carousel {
    background: rgba(10, 10, 10, 0.8);
    border: 1px solid var(--blood-red);
    border-radius: 10px;
    padding: 30px;
    margin-bottom: 40px;
    position: relative;
    min-height: 150px;
}

.quote {
    display: none;
    animation: fadeIn 1s;
}

.quote.active {
    display: block;
}

.quote p {
    font-size: 1.2rem;
    margin-bottom: 10px;
    text-align: center;
    font-style: italic;
}

.quote cite {
    display: block;
    text-align: right;
    color: var(--gold);
    font-size: 0.9rem;
}

@keyframes fadeIn {
    from {
        opacity: 0;
    }
    to {
        opacity: 1;
    }
}

/* Подвал */
.footer {
    text-align: center;
    padding: 20px 0 40px;
    border-top: 1px solid var(--blood-red);
    margin-top: 40px;
}

.disclaimer {
    font-size: 0.8rem;
    color: var(--light-gray);
    margin-top: 10px;
}

/* Адаптивность */
@media (max-width: 768px) {
    .title {
        font-size: 2.5rem;
    }
    
    .profile-card {
        flex-direction: column;
    }
    
    .interest-grid {
        grid-template-columns: 1fr;
    }
    
    .links-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}

/* Эффекты при наведении и нажатии */
.hover-effect:hover {
    cursor: pointer;
    transform: scale(1.02);
    transition: transform 0.2s;
}

.click-effect:active {
    transform: scale(0.98);
    transition: transform 0.1s;
}