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

    // Event listeners for date inputs
    if (dp1 && dp2) {
        dp1.addEventListener("change", updateEndDate);
        dp2.addEventListener("change", validateDates);
    }

    // Ensures that the end date is not before the start date
    function updateEndDate() {
        if (dp2.value < dp1.value) {
            dp2.value = dp1.value;
        }
        highlightDate();
    }

    // Validates that the end date is not before the start date
    function validateDates() {
        if (dp2.value < dp1.value) {
            alert("Data de final nu poate fi mai mică decât cea de început!");
            dp2.value = dp1.value;
        }
        highlightDate();
    }

    function renderCalendar(month, year) {
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
                    if (selectedStartDate && selectedEndDate && isDateInRange(date, month, year)) {
                        cell.classList.add('highlight');
                    }
                    date++;
                }
                row.appendChild(cell);
            }
            calendarBody.appendChild(row);
        }
    }

    function isDateInRange(date, month, year) {
        const currentDate = new Date(year, month, date);
        return currentDate >= selectedStartDate && currentDate <= selectedEndDate;
    }

    function highlightDate() {
        const startDatePicker = document.getElementById('start');
        const endDatePicker = document.getElementById('end');
        selectedStartDate = startDatePicker.value ? new Date(startDatePicker.value) : null;
        selectedEndDate = endDatePicker.value ? new Date(endDatePicker.value) : null;

        if (selectedStartDate) {
            selectedStartDate.setHours(0, 0, 0, 0);
            currentMonth = selectedStartDate.getMonth();  // Update current month to selected start date's month
            currentYear = selectedStartDate.getFullYear(); // Update current year
        }

        if (selectedEndDate) {
            selectedEndDate.setHours(23, 59, 59, 999);
            if (selectedEndDate < selectedStartDate) {
                endDatePicker.value = startDatePicker.value;
                selectedEndDate = new Date(selectedStartDate);
                selectedEndDate.setHours(23, 59, 59, 999);
            }
        }

        renderCalendar(currentMonth, currentYear);
    }

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
});