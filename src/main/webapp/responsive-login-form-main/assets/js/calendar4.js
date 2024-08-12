document.addEventListener("DOMContentLoaded", function() {
    const dp1 = document.getElementById("start");
    const dp2 = document.getElementById("end");
    const calendarBody = document.getElementById('calendar-body');
    const monthYear = document.getElementById('monthYear');
    const bg = "#32a852"; // Background color for highlighted dates
    const defaultBg = ""; // Default background color for non-selected dates
    let currentMonth = new Date().getMonth();
    let currentYear = new Date().getFullYear();

    const monthNames = ["Ian.", "Feb.", "Mar.", "Apr.", "Mai", "Iun.", "Iul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."];

    calendarBody.addEventListener('click', function(event) {
        if (event.target.tagName === 'TD' && event.target.getAttribute('data-date')) {
            handleDateClick(event.target.getAttribute('data-date'));
        }
    });

    function handleDateClick(clickedDate) {
        if (!dp1.value) {
            dp1.value = clickedDate;
        } else if (!dp2.value) {
            if (new Date(clickedDate) >= new Date(dp1.value)) {
                dp2.value = clickedDate;
            } else {
                dp1.value = clickedDate;
                dp2.value = '';
            }
        } else {
            dp1.value = clickedDate;
            dp2.value = '';
        }
        highlightDates();
    }

    function highlightDates() {
        const startDate = dp1.value ? new Date(dp1.value) : null;
        const endDate = dp2.value ? new Date(dp2.value) : null;

        Array.from(calendarBody.querySelectorAll('td[data-date]')).forEach(td => {
            const currentDate = new Date(td.getAttribute('data-date'));
            if (startDate && endDate && currentDate >= startDate && currentDate <= endDate) {
                td.classList.add('highlight');
                td.style.backgroundColor = bg;
            } else {
                td.classList.remove('highlight');
                td.style.backgroundColor = defaultBg; // Reset to default background color
            }
        });
    }
	
	   // Funcția de generare a calendarului

	   // Extragerea datelor din elementele ascunse și aplicarea evidențierii
	   const startDateText = document.getElementById("pstart").innerText;
	   const endDateText = document.getElementById("pend").innerText;
	   const startDate1 = new Date(startDateText);
	   const endDate1 = new Date(endDateText);

	   highlightDates1(startDate1, endDate1);
	   // Asumăm că există o funcție definită care populează calendarul
	   // Exemplu simplificat:

	   function highlightDates1(startDate, endDate) {
	       let cells = calendarBody.querySelectorAll('td[data-date]');
	       cells.forEach(function(cell) {
	           let dateOfCell = new Date(cell.getAttribute('data-date'));
	           if (dateOfCell >= startDate && dateOfCell <= endDate) {
	               cell.classList.add('highlight');
	               cell.style.backgroundColor = bg;
	           } else {
	               cell.classList.remove('highlight');
	               cell.style.backgroundColor = defaultBg;
	           }
	       });
	   }
	
    function renderCalendar(month, year) {
        calendarBody.innerHTML = '';
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
                    date++;
                }
                row.appendChild(cell);
            }
            calendarBody.appendChild(row);
        }
        highlightDates();
    }

    // Update and validate dates
    dp1.addEventListener("change", highlightDates);
    dp2.addEventListener("change", highlightDates);

    // Render the calendar
    renderCalendar(currentMonth, currentYear);
	    
	    function updateEndDate() {
	        if (dp2.value < dp1.value) {
	            dp2.value = dp1.value;
	        }
	        highlightDates();
	    }

	    function validateDates() {
	        if (dp2.value < dp1.value) {
	            alert("Data de final nu poate fi mai mică decât cea de început!");
	            dp2.value = dp1.value;
	        }
	        highlightDates();
	    }

	    function renderCalendar(month, year) {
	        calendarBody.innerHTML = '';
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
	                    date++;
	                }
	                row.appendChild(cell);
	            }
	            calendarBody.appendChild(row);
	        }
	        highlightDates();
	    }

	    dp1.addEventListener("change", function() {
	        updateEndDate();
	        highlightDates();
	    });

	    dp2.addEventListener("change", function() {
	        validateDates();
	        highlightDates();
	    });

	    renderCalendar(currentMonth, currentYear);
	
	
    function previousMonth() {
        if (currentMonth === 0) {
            currentMonth = 11;
            currentYear--;
        } else {
            currentMonth--;
        }
        renderCalendar(currentMonth, currentYear);
    }

    function nextMonth() {
        if (currentMonth === 11) {
            currentMonth = 0;
            currentYear++;
        } else {
            currentMonth++;
        }
        renderCalendar(currentMonth, currentYear);
    }

    document.querySelector('.prev').addEventListener('click', previousMonth);
    document.querySelector('.next').addEventListener('click', nextMonth);
    document.getElementById('start').addEventListener('change', highlightDate);
    document.getElementById('end').addEventListener('change', highlightDate);

    renderCalendar(currentMonth, currentYear);
	//if (dp1 && dp2) {
	    dp1.addEventListener("change", updateEndDate);
	    dp2.addEventListener("change", validateDates);
	    dp1.addEventListener("change", function() {
	        dp2.min = dp1.value;
	        if (dp2.value < dp1.value) {
	            dp2.value = ''; // Reset dp2 if it's less than dp1
	        }
	    });
//	}

	// Ensures that the end date is not before the start date
	function updateEndDate() {
	    if (dp2.value < dp1.value) {
	        dp2.value = dp1.value;
	    }
	    highlightDate();
	}
});