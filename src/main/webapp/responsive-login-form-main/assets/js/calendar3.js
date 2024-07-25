document.addEventListener("DOMContentLoaded", function() {
    const dp1 = document.getElementById("start");
    const dp2 = document.getElementById("end");
    const monthYear = document.getElementById('monthYear');
    const calendarBody = document.getElementById('calendar-body');

    let currentMonth = new Date().getMonth();
    let currentYear = new Date().getFullYear();
    let selectedStartDate = null;
    let selectedEndDate = null;
	
    const monthNames = ["Ian.", "Feb.", "Mar.", "Apr.", "Mai", "Iun.", "Iul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."];

	function renderCalendar(month, year) {
	    const calendarBody = document.getElementById('calendar-body');
	    calendarBody.innerHTML = ''; // Clear existing entries
	    let firstDay = (new Date(year, month).getDay() + 6) % 7;
	    let daysInMonth = 32 - new Date(year, month, 32).getDate();
	    let date = 1;

	    monthYear.textContent = monthNames[month] + " " + year;

	    for (let i = 0; i < 6; i++) {
	        let row = document.createElement('tr');
	        for (let j = 0; j < 7; j++) {
	            let cell = document.createElement('td');
				
	            if (i === 0 && j < firstDay || date > daysInMonth) {
	                cell.textContent = '';
	            } else {
	                let fullDate = `${year}-${(month + 1).toString().padStart(2, '0')}-${date.toString().padStart(2, '0')}`;
	                cell.setAttribute('data-date', fullDate);
	                cell.textContent = date;
	                
	                // Apply classes and tooltips
	                let leaveClass = getLeaveClass(leaveData[fullDate] ? leaveData[fullDate].length : 0);
	                cell.className += leaveClass; // This ensures only the leave class is applied directly
	                
	                date++;
	            }
	            row.appendChild(cell);
	        }
	        calendarBody.appendChild(row);
	    }
	}

	function getLeaveClass(count) {
	    if (!count) return ''; // No leaves
	    if (count === 1) return 'leave-1';
	    if (count === 2) return 'leave-2';
	    if (count === 3) return 'leave-3';
	    if (count > 3) return 'leave-more';
	    return '';
	}

    function highlightDate() {
        selectedStartDate = dp1.value ? new Date(dp1.value) : null;
        selectedEndDate = dp2.value ? new Date(dp2.value) : null;

        if (selectedStartDate) {
            selectedStartDate.setHours(0, 0, 0, 0);
            currentMonth = selectedStartDate.getMonth();
            currentYear = selectedStartDate.getFullYear();
        }

        if (selectedEndDate) {
            selectedEndDate.setHours(23, 59, 59, 999);
            if (selectedEndDate < selectedStartDate) {
                dp2.value = dp1.value;
                selectedEndDate = new Date(selectedStartDate);
                selectedEndDate.setHours(23, 59, 59, 999);
            }
        }

        renderCalendar(currentMonth, currentYear);
    }

    function previousMonth() {
        currentMonth = (currentMonth === 0) ? 11 : currentMonth - 1;
        currentYear = (currentMonth === 11) ? currentYear - 1 : currentYear;
        renderCalendar(currentMonth, currentYear);
		updateCalendarDisplay();
    }

    function nextMonth() {
        currentMonth = (currentMonth + 1) % 12;
        currentYear = (currentMonth === 0) ? currentYear + 1 : currentYear;
        renderCalendar(currentMonth, currentYear);
		updateCalendarDisplay();
    }

    document.querySelector('.navigation button:first-child').addEventListener('click', previousMonth);
    document.querySelector('.navigation button:last-child').addEventListener('click', nextMonth);

    renderCalendar(currentMonth, currentYear);
	
	function updateCalendarDisplay(year, month) {
	        const monthNames = ["Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie", "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"];
	        document.getElementById('monthYear').textContent = `${monthNames[month]} ${year}`;
	        fetchCalendarData(year, month);
	    }

	    function fetchCalendarData(year, month) {
	        fetch(`testviewpers.jsp?year=${year}&month=${month+1}`)
	            .then(response => response.text())
	            .then(html => {
	                document.innerHTML = html;
					updateCalendar();
	            })
	            .catch(error => console.error('Error fetching data:', error));
	    }

	    // Inițializare cu luna și anul curent
	    let today = new Date();
	    updateCalendarDisplay(today.getFullYear(), today.getMonth());
		
		function updateCalendar() {
		        const cells = document.querySelectorAll('#calendar-body td[data-date]');
		        cells.forEach(cell => {
		            const date = cell.getAttribute('data-date');
		            const leaveCount = leaveDataByDate[date] || 0;
		            // Aplicarea stilului pe baza numărului de concedii
		            cell.className = getLeaveClass(leaveCount);
		            cell.title = leaveCount + " persoane în concediu"; // Tooltip informativ
		        });
		    }

		    function getLeaveClass(count) {
		        if (count === 0) return '';
		        if (count === 1) return 'leave-1';
		        if (count === 2) return 'leave-2';
		        if (count === 3) return 'leave-3';
		        if (count > 3) return 'leave-more';
		    }

		    // Așteaptă să se încarce datele înainte de a actualiza calendarul
		    if (typeof leaveDataByDate !== 'undefined') {
		        updateCalendar();
		    }
			

			   // Actualizează display-ul calendarului
			   function updateCalendarDisplay() {
			       monthYear.textContent = `${getMonthName(currentMonth)} ${currentYear}`;
			       fetchCalendarData(currentMonth, currentYear).then(() => {
			           updateCalendar(); // Actualizează calendarul după ce datele sunt încărcate
			       });
			   }

			   // Obține numele lunii
			   function getMonthName(month) {
			       const monthNames = ["Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie",
			                           "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"];
			       return monthNames[month];
			   }

			   // Solicită datele pentru calendar de la server
			   function fetchCalendarData(month, year) {
			       return fetch(`testviewpers.jsp?year=${year}&month=${month + 1}`)
			           .then(response => response.json())
			           .then(data => {
			               window.leaveDataByDate = data; // Salvează datele într-o variabilă globală
			           })
			           .catch(error => console.error('Error fetching data:', error));
			   }

			   // Actualizează calendarul cu datele încărcate
			   function updateCalendar() {
			       const cells = document.querySelectorAll('#calendar-body td[data-date]');
			       cells.forEach(cell => {
			           const date = cell.getAttribute('data-date');
			           const leaveCount = jsonData[date] || 0;
					   console.log(leaveCount);
			           cell.className = getLeaveClass(leaveCount); // Aplică clasa corespunzătoare
			       });
			   }

			   // Determină clasa pe baza numărului de persoane în concediu
			   function getLeaveClass(count) {
			       if (count === 0) return '';
			       if (count === 1) return 'leave-1';
			       if (count === 2) return 'leave-2';
			       if (count === 3) return 'leave-3';
			       return 'leave-more'; // Pentru 4 sau mai multe persoane
			   }

			   // Încarcă inițial datele pentru luna curentă
			   updateCalendarDisplay();
			   //if (dp1 && dp2) {
			       dp1.addEventListener("change", updateEndDate);
			       dp2.addEventListener("change", validateDates);
			       dp1.addEventListener("change", function() {
			           dp2.min = dp1.value;
			           if (dp2.value < dp1.value) {
			               dp2.value = ''; // Reset dp2 if it's less than dp1
			           }
			       });
			  // }

			   // Ensures that the end date is not before the start date
			   function updateEndDate() {
			       if (dp2.value < dp1.value) {
			           dp2.value = dp1.value;
			       }
			       highlightDate();
			   }
});