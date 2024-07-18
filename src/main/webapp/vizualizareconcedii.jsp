<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Dynamic Content Loading</title>
<style>
    body, html {
        margin: 0;
        padding: 0;
        height: 100%; /* Ensure the html and body occupy full height */
    }
    table {
        width: 100%; /* Ensure table uses full width of the view */
        background-color: #f4f4f4;
        border-collapse: collapse;
    }
    iframe {
        width: 100%; /* Full width */
        transition: height 0.5s ease; /* Smooth transition for height changes */
        height: 0; /* Start with iframe minimized */
        border: none; /* No border for a cleaner look */
    }
</style>
</head>
<body>
<table>
    <tr>
        <td><a href="viewconcoldepeu.jsp" class="load-content" target="iframe">Coleg_departament</a></td>
        <td><a href="viewcol.jsp" class="load-content" target="iframe">Angajat</a></td>
        <td><a href="viewp.jsp" class="load-content" target="iframe">Concedii personale</a></td>
        <td><a href="viewdepeu.jsp" class="load-content" target="iframe">Din departamentul meu</a></td>
        <td><a href="viewcondep.jsp" class="load-content" target="iframe">Dintr-un departament</a></td>
        <td><a href="viewtot.jsp" class="load-content" target="iframe">Din toata institutia</a></td>
    </tr>
</table>
<iframe id="iframe" name="iframe" src="about:blank" style="border:none;"></iframe>

<script>
    document.querySelectorAll('.load-content').forEach(link => {
        link.addEventListener('click', function(event) {
            const iframe = document.getElementById('iframe');
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
