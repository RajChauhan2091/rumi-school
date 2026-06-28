/**
 * Internet Connectivity Detection
 * Monitors online/offline status and displays a notification to the user
 */

(function () {
    const offlineModalId = 'offlineModal';
    const offlineAlertId = 'offlineAlert';

    // Initialize connectivity check on page load
    function initConnectivityCheck() {
        // Check initial status
        updateConnectivityStatus();

        // Listen for online/offline events
        window.addEventListener('online', handleOnline);
        window.addEventListener('offline', handleOffline);

        // Periodic check (every 5 seconds) for more reliability
        setInterval(updateConnectivityStatus, 5000);
    }

    // Update connectivity status
    function updateConnectivityStatus() {
        if (navigator.onLine) {
            hideOfflineAlert();
        } else {
            showOfflineAlert();
        }
    }

    // Handle when internet comes online
    function handleOnline() {
        console.log('[Connectivity] Internet is now ONLINE');
        hideOfflineAlert();
    }

    // Handle when internet goes offline
    function handleOffline() {
        console.log('[Connectivity] Internet is now OFFLINE');
        showOfflineAlert();
    }

    // Show offline alert/modal
    function showOfflineAlert() {
        const alertElement = document.getElementById(offlineAlertId);
        if (alertElement) {
            alertElement.style.display = 'flex';
            alertElement.classList.add('show');
        }
    }

    // Hide offline alert/modal
    function hideOfflineAlert() {
        const alertElement = document.getElementById(offlineAlertId);
        if (alertElement) {
            alertElement.style.display = 'none';
            alertElement.classList.remove('show');
        }
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initConnectivityCheck);
    } else {
        initConnectivityCheck();
    }

    // Expose for debugging
    window.ConnectivityCheck = {
        checkStatus: updateConnectivityStatus,
        isOnline: () => navigator.onLine,
        showOffline: showOfflineAlert,
        hideOffline: hideOfflineAlert
    };
})();
