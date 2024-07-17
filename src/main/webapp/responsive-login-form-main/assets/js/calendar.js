        let today = new Date();
        let currentMonth = today.getMonth();
        let currentYear = today.getFullYear();
        let selectedStartDate = null;
        let selectedEndDate = null;

        const monthNames = ["Ian.", "Feb.", "Mar.", "Apr.", "Mai", "Iun.",
            "Iul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."];

        function generateCalendar(month, year) {
            let firstDay = (new Date(year, month)).getDay();
            let daysInMonth = 32 - new Date(year, month, 32).getDate();
            let tbl = document.getElementById("calendar-body");
            tbl.innerHTML = "";

            document.getElementById("monthYear").innerHTML = monthNames[month] + " " + year;

            // Adjust first day to be Monday-based
            firstDay = (firstDay === 0) ? 6 : firstDay - 1;

            let date = 1;
            for (let i = 0; i < 6; i++) {
                let row = document.createElement("tr");

                for (let j = 0; j < 7; j++) {
                    if (i === 0 && j < firstDay) {
                        let cell = document.createElement("td");
                        let cellText = document.createTextNode("");
                        cell.appendChild(cellText);
                        row.appendChild(cell);
                    } else if (date > daysInMonth) {
                        break;
                    } else {
                        let cell = document.createElement("td");
                        let cellText = document.createTextNode(date);
                        cell.appendChild(cellText);
                        if (selectedStartDate && selectedEndDate && isDateInRange(date, month, year)) {
                            cell.classList.add('highlight');
                        }
                        row.appendChild(cell);
                        date++;
                    }
                }

                tbl.appendChild(row);
            }
        }

        function isDateInRange(day, month, year) {
            let date = new Date(year, month, day);
            // Adjust for time zone offset
            date.setHours(0, 0, 0, 0);
            return date >= selectedStartDate && date <= selectedEndDate;
        }

        function highlightDate() {
            const startDatePicker = document.getElementById('startDate');
            const endDatePicker = document.getElementById('endDate');
            selectedStartDate = startDatePicker.value ? new Date(startDatePicker.value) : null;
            selectedEndDate = endDatePicker.value ? new Date(endDatePicker.value) : null;

            if (selectedStartDate) selectedStartDate.setHours(0, 0, 0, 0); // Adjust for time zone offset
            if (selectedEndDate) selectedEndDate.setHours(23, 59, 59, 999); // Include the entire end date

            generateCalendar(currentMonth, currentYear);
            calculateDifference();
        }

        function calculateDifference() {
            const differenceElement = document.getElementById('difference');
            if (selectedStartDate && selectedEndDate) {
                const diffTime = Math.abs(selectedEndDate - selectedStartDate);
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)); // Include the end date in count
                differenceElement.textContent = `Concediul dureaza ${diffDays} zile.`;
            } else {
                differenceElement.textContent = '';
            }
        }

        function previousMonth() {
            currentYear = (currentMonth === 0) ? currentYear - 1 : currentYear;
            currentMonth = (currentMonth === 0) ? 11 : currentMonth - 1;
            generateCalendar(currentMonth, currentYear);
        }

        function nextMonth() {
            currentYear = (currentMonth === 11) ? currentYear + 1 : currentYear;
            currentMonth = (currentMonth + 1) % 12;
            generateCalendar(currentMonth, currentYear);
        }

        generateCalendar(currentMonth, currentYear);