async function get_GS() {
    let response = await fetch("http://localhost:8000/api/GS/all");
    if (response.ok) {
        let json = await response.json();
        return json;
    } else {
        alert("Ошибка HTTP: " + response.status);
    }
}

async function render_GS() {
    let template = `
<div class="card card-2" style="width: 18rem;">
    <div class="card-body">
        <h5 class="card-title"><u>Конфигурация___________</u></h5>
        <div class="acesor">
            <div style="text-decoration: underline;">
                <p>Процессор</p>
                <p class="card-text">Видеокарта</p>
                <p class="card-text">Оперативная<br>память</p>
            </div>
            <div class="gso" style="text-decoration: underline;">
                <p>{ПроизводительПроцессора}<br>{МодельПроцессора}</p>
                <p>{ПроизводительВидеокарты}<br>{МодельВидеокарты}</p>
                <p>{ОбъёмОП}<br>{ГцОП}</p>
            </div>
        </div>
    </div>
</div>`;
let GSs = await get_GS();
    let container = document.getElementById("GS");
    GSs.forEach(element => {
        let GS = template
            .replace("{ПроизводительПроцессора}", element.ПроизводительПроцессора)
            .replace("{МодельПроцессора}", element.МодельПроцессора)
            .replace("{ПроизводительВидеокарты}", element.ПроизводительВидеокарты)
            .replace("{МодельВидеокарты}", element.МодельВидеокарты)
            .replace("{ОбъёмОП}", element.ОбъёмОП)
            .replace("{ГцОП}", element.ГцОП)
        container.innerHTML += GS;
    });
}
render_GS();
