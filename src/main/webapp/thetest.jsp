<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <link rel="stylesheet" type="text/css" href="stylesheet.css">
    <title>Acasa</title>
    <style>
        iframe {
            width: 100%;
            border: none;
            transition: height 0.5s ease;
        }
    </style>
</head>

<body>

    <div class="sidebar">
        <ul>
            <li class="logo" style="--bg: #333;">
                <a href="#">
                    <div class="siicon">
                        <ion-icon name="airplane"></ion-icon>
                    </div>
                    <div class="sitext">Concedii</div>
                </a>
            </li>
            <div class="menuToggle"></div>
            <div class="menulist">
                <li style="--bg: #3F48CC;;"  class="active">
                    <a href="#">
                        <div class="siiconn">
                            <ion-icon name="home"></ion-icon>
                        </div>
                        <div class="sitextt">Acasa</div>
                    </a>
                </li>
                <li style="--bg: #3F48CC;;">
                    <a href="#">
                        <div class="siiconn">
                            <ion-icon name="people"></ion-icon>
                        </div>
                        <div class="sitextt">Angajati</div>
                    </a>
                </li>
                <li style="--bg: #3F48CC;;">
                    <a href="#">
                        <div class="siiconn">
                            <ion-icon name="today"></ion-icon>
                        </div>
                        <div class="sitextt">Notificari</div>
                    </a>
                </li>
                <li style="--bg: #3F48CC;">
                    <a href="#">
                        <div class="siiconn">
                            <ion-icon name="stats"></ion-icon>
                        </div>
                        <div class="sitextt">Rapoarte</div>
                    </a>
                </li>
                <li style="--bg: #3F48CC;;">
                    <a href="#">
                        <div class="siiconn">
                            <ion-icon name="switch"></ion-icon>
                        </div>
                        <div class="sitextt">Configurari</div>
                    </a>
                </li>
                <li style="--bg: #3F48CC;;">
                    <a href="#">
                        <div class="siiconn">
                            <ion-icon name="apps"></ion-icon>
                        </div>
                        <div class="sitextt">Actiuni</div>
                    </a>
                </li>
                <li style="--bg: #3F48CC;;">
                    <a href="#">
                        <div class="siiconn">
                            <ion-icon name="briefcase"></ion-icon>
                        </div>
                        <div class="sitextt">Departamente</div>
                    </a>
                </li>
            </div>
            
            <div class="sibottom">
                <li style="--bg:#333;">
                    <a href="#">
                        <div class="siiconn">
                            <div class="imgbx">
                                <img src="https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png">
                            </div>
                        </div>
                        <div class="sitextt">Director</div>
                    </a>
                </li>
                <li style="--bg: #333;">
                    <a href="#">
                        <div class="siiconn">
                            <ion-icon name="share-alt"></ion-icon>
                        </div>
                        <div class="sitextt">Deconectare</div>
                    </a>
                </li>
                
            </div>
        </ul>
    </div>
    <div class="main-content">
        <iframe name="iframe" id='iframe' src="about:blank"></iframe>
    </div>
    <script src="main.js"></script>
    <script src="https://unpkg.com/ionicons@4.5.10-0/dist/ionicons.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const iframe = document.getElementById('iframe');
            const links = document.querySelectorAll('.load-content');

            links.forEach(link => {
                link.addEventListener('click', function(event) {
                    event.preventDefault();
                    iframe.src = this.href;
                });
            });

            iframe.onload = function() {
                const iframeDocument = iframe.contentDocument || iframe.contentWindow.document;
                iframe.style.height = iframeDocument.documentElement.scrollHeight + 'px';
            };
        });
    </script>
</body>

</html>
