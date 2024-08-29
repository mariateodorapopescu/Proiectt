let menuToggle = document.querySelector('.menuToggle');
let sidebar = document.querySelector('.sidebar');
menuToggle.onclick = function() {
    menuToggle.classList.toggle('active');
    sidebar.classList.toggle('active');
}
let menulist = document.querySelectorAll('.menulist li');

function activeLink() {
    menulist.forEach((item) => item.classList.remove('active'));
    this.classList.add('active');
}
menulist.forEach((item) => item.addEventListener('click', activeLink));