document.addEventListener('DOMContentLoaded', () => {
alert("userregistration.js loaded");
    const registrationform = document.getElementById("registrationForm");
    const outputDiv = document.getElementById("responseMessage");
    
    registrationform.addEventListener("submit", async (event) => {
        event.preventDefault()
    
        const username = document.getElementById("username").value;
        const password = document.getElementById("password").value;
    
        // Create a FormData object to easily handle form data
        const formData = new FormData();
        formData.append('username', username);
        formData.append('password', password);

    try{
        const response = await fetch('/api/register', {
            method: 'POST',
            body: formData
        });
        if (response.ok) {
            const result = await response.json();
            outputDiv.textContent = `Registration successful! Welcome, ${result.name}`;
            outputDiv.style.color = 'green';
            registrationForm.reset();
        } else {
            outputDiv.textContent = `Registration failed with status: ${response.status}`;
        }
    }catch(error) {
        console.error('Error during registration:', error);
        outputDiv.textContent = `An error occurred during registration. Please try again later.`;
        outputDiv.style.color = 'red';
        }
    });

});