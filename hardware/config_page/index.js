document.addEventListener('DOMContentLoaded', function() {
  /*initialize animations*/
  document.getElementsByTagName('body')[0].classList.add('is-loading');
  window.addEventListener('load', function() {
    window.setTimeout(function() {
      document.getElementsByTagName('body')[0].classList.remove('is-loading');
    }, 250);
  });

  /*wifi setup*/
  function validateSSID(useTrim) {
    var ssid = document.forms['wifi']['ssid'].value;
    if (useTrim === true) ssid = ssid.trim();
    if (!ssid) {
      document.forms['wifi']['ssid'].classList.add('validation-error');
      document.forms['wifi']['ssid'].value = '';
      document.forms['wifi']['ssid'].placeholder = 'This field can not be empty.';
    } else {
      document.forms['wifi']['ssid'].classList.remove('validation-error');
    }
  }
  document.forms['wifi']['ssid'].addEventListener('input', validateSSID);

  document.getElementById('start-setup').addEventListener('click', nextSlide);
  document.getElementById('all-done').addEventListener('click', function(){
    nextSlide();
    restartESP();
  });
  /*test connection handler*/
  document.getElementById('test-connection').addEventListener('click', function() {
    event.preventDefault();
    /*validations*/
    validateSSID(true);
    if (document.forms['wifi']['ssid'].classList.contains('validation-error'))
    {
      return false;
    }
    nextSlide();
    document.getElementById('wifi-error-text').parentNode.classList.add("hidden");
    ajaxRequest('http://going-postal.config/wifi/config', serialize(document.forms['wifi']),
             pingStatus, wifiErrorHandler)
  });
});

function wifiErrorHandler(body, status) {
  document.getElementById('wifi-error-text').innerText = body;
  document.getElementById('wifi-error-text').parentNode.classList.remove("hidden");
  previousSlide();
};

function pingStatus() {
  setTimeout(function() {
    ajaxRequest('http://going-postal.config/wifi/status', '', function(body, status) {
      if (status == 202) {
        pingStatus();
      } else {
        nextSlide();
      }
    }, wifiErrorHandler, 5000, pingStatus, pingStatus);
  }, 500);
}

function restartESP() {
  setTimeout(function() {
    ajaxRequest('http://going-postal.config/restart', '', function(){}, restartESP, null, null, restartESP);
  }, 500);
}

function currentSlide() {
  return document.getElementsByClassName('slide-in')[0];
}

function nextSlide() {
  var el = currentSlide();
  el.classList.remove('slide-in');
  el.classList.add('slide-away');
  el.nextElementSibling.classList.add('slide-in');
  event.preventDefault();
}

function previousSlide() {
  var el = currentSlide();
  el.classList.remove('slide-in');
  el.previousElementSibling.classList.remove('slide-away');
  el.previousElementSibling.classList.add('slide-in');
  event.preventDefault();
}

function ajaxRequest(url, data, success, error, timeout, onTimeout, onError) {
  var request = new XMLHttpRequest();
  if (data != '') {
    url = url + "?" + data
  }
  request.open('GET', url, true);

  request.onload = function() {
    if (request.status >= 200 && request.status < 400) {
      success(request.responseText, request.status);
    } else {
      error(request.responseText, request.status);
    }
  };

  if (onError) {
    request.onerror = onError;
  } else {
    request.onerror = function() {
      currentSlide().innerHTML = '<div class="error limit-width center">Unrecoverable error has occured.<br /> Please restart the device and try again.</div>';
    };
  }

  if (timeout) {
    request.timeout = timeout;
    request.ontimeout = onTimeout;
  }
  request.send();
}
