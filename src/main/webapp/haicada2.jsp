
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8' />


  <title>
    Test
  </title>


<link href='/docs/dist/demo-to-codepen.css' rel='stylesheet' />

  <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js'></script>

<script src='/docs/dist/demo-to-codepen.js'></script>

  <script src='https://cdn.jsdelivr.net/npm/@fullcalendar/core@6.1.15/locales-all.global.min.js'></script>
<script>

  document.addEventListener('DOMContentLoaded', function() {
    var initialLocaleCode = 'ro';
    var localeSelectorEl = document.getElementById('locale-selector');
    var calendarEl = document.getElementById('calendar');

    var calendar = new FullCalendar.Calendar(calendarEl, {
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay,listMonth'
      },
      locale: initialLocaleCode,
      buttonIcons: true, // show the prev/next text
      weekNumbers: false,
      navLinks: true, // can click day/week names to navigate views
      editable: true,
      dayMaxEvents: true, // allow "more" link when too many events
      events: [{"color":"#88D66C","start":"2024-07-13","end":"2024-07-20","title":"Eremia Catalin Constantin","textColor":"white"},{"color":"#88D66C","start":"2024-09-15","end":"2024-09-18","title":"Eremia Catalin Constantin","textColor":"white"},{"color":"#10439F","start":"2024-07-15","end":"2024-07-18","title":"Rebreanu Cecilia Ioana","textColor":"white"},{"color":"#10439F","start":"2024-07-22","end":"2024-07-27","title":"Rebreanu Cecilia Ioana","textColor":"white"},{"color":"#10439F","start":"2024-09-17","end":"2024-09-27","title":"Rebreanu Cecilia Ioana","textColor":"white"},{"color":"#10439F","start":"2024-09-29","end":"2024-10-16","title":"Rebreanu Cecilia Ioana","textColor":"white"},{"color":"#88D66C","start":"2024-07-25","end":"2024-07-28","title":"Eremia Catalin Constantin","textColor":"white"},{"color":"#88D66C","start":"2024-09-25","end":"2024-09-29","title":"Eremia Catalin Constantin","textColor":"white"}]

    });

    calendar.render();

  });
  
</script>
<style>

  body {
    margin: 0;
    padding: 0;
    font-family: Arial, Helvetica Neue, Helvetica, sans-serif;
    font-size: 14px;
  }

  #top {
    background: #eee;
    border-bottom: 1px solid #ddd;
    padding: 0 10px;
    line-height: 40px;
    font-size: 12px;
  }

  #calendar {
    max-width: 1100px;
    margin: 40px auto;
    padding: 0 10px;
  }

</style>
</head><body>

  <div id='calendar'></div>

</body>

</html>
