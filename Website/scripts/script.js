load("navigation-bar", "common/navigation-bar.html");
load("footer", "common/footer.html");

// Code below is jQuery's .load() converted to vanilla JavaScript.
// load's source: https://stackoverflow.com/a/45529432

function load(id, url) {
    fetch(url)
        .then((response) => response.text())
        .then((html) => {
            setInnerHtml(id, html);
        });
}

// Code below is needed to run JavaScript from the fetched HTML.
// setInnerHtml's source: https://stackoverflow.com/a/47614491

function setInnerHtml(id, html) {
    element = document.querySelector("#" + id);
    element.innerHTML = html;

    Array.from(element.querySelectorAll("script")).forEach((oldScript) => {
        const newScript = document.createElement("script");
        Array.from(oldScript.attributes).forEach((attr) =>
            newScript.setAttribute(attr.name, attr.value)
        );
        newScript.appendChild(document.createTextNode(oldScript.innerHTML));
        oldScript.parentNode.replaceChild(newScript, oldScript);
    });
}

function copyEmailAddress() {
    window.prompt("Copy to clipboard!", "csbuddiesapp@gmail.com");
}
