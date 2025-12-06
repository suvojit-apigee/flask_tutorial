// static/spa_user_management.js
document.addEventListener("DOMContentLoaded", function () {
  // Store user data (in-memory for this SPA, lost on full page reload)
  let users = [];

  // Function to show/hide pages and update active nav link
  function navigateTo(pageId) {
    // Hide all pages
    document.querySelectorAll(".page").forEach((page) => {
      page.classList.remove("active");
    });

    // Deactivate all nav links
    document.querySelectorAll("nav a").forEach((link) => {
      link.classList.remove("active");
    });

    // Show the requested page
    const activePage = document.getElementById(pageId);
    if (activePage) {
      activePage.classList.add("active");
    }

    // Activate the corresponding nav link
    const activeNav = document.querySelector(
      `nav a[href="#${pageId.replace("-page", "")}"]`
    );
    if (activeNav) {
      activeNav.classList.add("active");
    }
  }

  // Function to handle form submission
  function addUser() {
    const registrationForm = document.getElementById("registration-form");

    registrationForm.addEventListener("submit", async (event) => {
      event.preventDefault();

      const outputDiv = document.getElementById("message");
      const username = document.getElementById("username").value;
      const password = document.getElementById("password").value;
      const email = document.getElementById("email").value;
      const phone = document.getElementById("phone").value;

      // Create a form data to send to the server
      const formData = new FormData();
      formData.append("username", username);
      formData.append("password", password);
      formData.append("email", email);
      formData.append("phone", phone);

      try {
        const response = await fetch("/api/register", {
          method: "POST",
          body: formData,
        });
        result = await response.json();
        const status = result.status || response.status;
        console.log("Registration response status:", status);
        if (status=== 200) {
          console.log(`Inside success block of status == 200, data: ${JSON.stringify(result)}`);
          const dataOutput = result.data || {};
          const name = dataOutput.username || username;
          console.log("Registration response username:", name);
          outputDiv.textContent = `Registration successful! Welcome, ${name}`;
          outputDiv.style.color = "green";
          registrationForm.reset();
        } else {
          outputDiv.textContent = `Registration failed with status: ${result.message}`;
          registrationForm.reset();  
        }
      } catch (error) {
        console.error("Error during registration:", error);
        const errorMessage = result.message || "Unknown error";
        outputDiv.textContent = `Registration failed: ${errorMessage}`;
        outputDiv.style.color = "red";
        registrationForm.reset();
      }

      setTimeout(() => {
        outputDiv.textContent = "";
      }, 3000);
    });
  }
  // Function to update the view user details table
  async function updateUserDetails() {
    const viewMessageDiv = document.getElementById("view-message");
    viewMessageDiv.textContent = "";
    const tbody = document.getElementById("user-details-body");
    tbody.innerHTML = ""; // Clear existing entries

    try {
      const response = await fetch("/api/users", {
        method: "GET",
      });
      if (response.ok) {
        users = await response.json();
        console.log("Fetched user details:", users);
        if(users.data.length > 0){
          const userList = users.data.map(user => ({
            username: user.username,
            email: user.email,
            phone: user.phone
          }));
          userList.forEach((user) => {
            const row = document.createElement("tr");
            row.innerHTML = `
                      <td>${user.username}</td>
                      <td>${user.email}</td>
                      <td>${user.phone}</td>
                  `;
            tbody.appendChild(row);
          });
        } else {
          tbody.innerHTML = "";
          viewMessageDiv.textContent = "No user details available.";  
        }
      } else {
        tbody.innerHTML = "";
        viewMessageDiv.textContent = `Failed to load user details with status: ${response.status}`;
      }
    } catch (error) {
      console.error("Error fetching user details:", error);
      viewMessageDiv.textContent =
        "An error occurred while loading user details. Please try again later.";
    }
  }

  // Event listeners for navigation links
  document
    .getElementById("nav-register")
    .addEventListener("click", function (e) {
      e.preventDefault();
      navigateTo("register-page");
    });

  // Setup form submission handler
  addUser();

  document.getElementById("nav-view").addEventListener("click", function (e) {
    e.preventDefault();
    updateUserDetails()
      .then(() => {
        navigateTo("view-page");
        console.log("View Details updated.");
      })
      .catch((error) => {
        console.error("Error updating user details:", error);
      });
  });

  // Initial page load navigation (optional, but good practice for direct access via URL hash)
  window.addEventListener("hashchange", () => {
    const pageId = window.location.hash.replace("#", "") + "-page";
    if (document.getElementById(pageId)) {
      navigateTo(pageId);
    } else {
      navigateTo("register-page"); // Default to registration if hash is invalid
    }
  });

  // Load initial page based on URL hash or default to register
  if (window.location.hash) {
    navigateTo(window.location.hash.replace("#", "") + "-page");
  } else {
    navigateTo("register-page");
  }
});
