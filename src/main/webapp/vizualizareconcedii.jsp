<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Dynamic Content Loading</title>
<style>
    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
    }
    body, html {
        font-family: 'Arial', sans-serif;
        background: linear-gradient(120deg, #a6c0fe 0%, #f68084 100%);
        height: 100%;
        display: flex;
        flex-direction: column;
        justify-content: flex-end;
        align-items: stretch;
        color: #fff;
         margin: 0;
        padding: 0;
    }
    table {
        width: 100%;
        min-width: 300px; /* Limit maximum width */
        background-color: rgba(255, 255, 255, 0.1);
        border-radius: 8px;
        top: 0;
        left: 0;
        position: fixed;
         border-collapse: collapse;
    }
    th, td {
        padding: 12px 15px;
        text-align: center;
        transition: background-color 0.3s;
        height:10vh;
    }
    a {
        color: #fff;
        text-decoration: none;
        font-size: 14px; /* Adjust font size for smaller screens */
        transition: color 0.3s;
    }
    a:hover {
        color: #000;
        background-color: rgba(255, 255, 255, 0.2);
        padding: 30px;
        padding-bottom: 25px;
        margin: 0;
    }
    a:active {
        color: #000;
        background-color: rgba(255, 255, 255, 0.2);
         padding: 30px;
        padding-bottom: 25px;
        margin: 0;
    }
    a:focus {
        color: #000;
        background-color: rgba(255, 255, 255, 0.2);
         padding: 30px;
        padding-bottom: 25px;
        margin: 0;
    }
    iframe {
        width: 100%;
        transition: height 0.5s ease;
        height: 0; /* Initially hidden */
        border: none;
    }
    
</style>
</head>
<body>
<table>
    <tr>
        <td><a href="viewconcoldepeu.jsp" class="load-content" target="iframee">Coleg_departament</a></td>
        <td><a href="viewcol.jsp" class="load-content" target="iframee">Angajat</a></td>
        <td><a href="viewp.jsp" class="load-content" target="iframee">Concedii personale</a></td>
        <td><a href="viewdepeu.jsp" class="load-content" target="iframee">Din departamentul meu</a></td>
        <td><a href="viewcondep.jsp" class="load-content" target="iframee">Dintr-un departament</a></td>
        <td><a href="viewtot.jsp" class="load-content" target="iframee">Din toata institutia</a></td>
         <td><a href="pean.jsp" class="load-content" target="iframee">Raport pe an</a></td>
          <td><a href="sometest.jsp" class="load-content" target="iframee">Raport lunar</a></td>
          <td><a href="testviewpers.jsp" class="load-content" target="iframee">Calendar</a></td>
        <!-- <td><a href="about:blank" class="load-content">Inapoi</a></td> -->
    </tr>
</table>
<iframe name="iframee" id='iframee' src="#"></iframe>
<script>
    document.querySelectorAll('.load-content').forEach(link => {
        link.addEventListener('click', function(event) {
            const iframe = document.getElementById('iframee');
            // Check if iframe is already expanded
            if (iframe.style.height === '0px' || iframe.style.height === '0') {
                iframe.style.height = '90vh'; // Expand the iframe
            } else {
                iframe.style.height = '0'; // Minimize the iframe
                // Optional: if you want to keep the iframe expanded unless explicitly minimized
               
            }
        });
        setTimeout(() => {
            iframe.style.height = '90vh';
        }, 500); // Delay to allow the iframe to load content before expanding
    });
</script>
</body>
</html>
