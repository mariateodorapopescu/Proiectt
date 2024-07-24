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
        
        <td><a href="viewp.jsp" class="load-content" target="iframee">Concedii personale</a></td>
        <td><a href="viewdepeu.jsp" class="load-content" target="iframee">Din departamentul meu</a></td>
         <td><a href="pean2.jsp" class="load-content" target="iframee">Raport pe an</a></td> 
          <td><a href="sometest2.jsp" class="load-content" target="iframee">Raport lunar</a></td>
          <td><a href="testviewpers2.jsp" class="load-content" target="iframee">Calendar</a></td> <!-- tre sa fac pentru departamentul meu -> de vazut cum -->
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
