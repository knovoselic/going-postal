document.addEventListener('DOMContentLoaded', function() {
  /*initialize animations*/
  document.getElementsByTagName("body")[0].classList.add('is-loading');
  window.addEventListener('load', function() {
    window.setTimeout(function() {
      document.getElementsByTagName("body")[0].classList.remove('is-loading');
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
    var errorHandler = function(body, status) {
      document.getElementById('wifi-error-text').innerText = body;
      document.getElementById('wifi-error-text').parentNode.classList.remove("hidden");
      previousSlide();
    };
    ajaxPost('http://going-postal.config/wifi/config', serialize(document.forms['wifi']), function() {
      // connection was successfully initiated - ping for status
      var pingStatus = function() {
        ajaxPost('http://going-postal.config/wifi/status', '', function(body, status) {
          if (status == 202) {
            setTimeout(pingStatus, 100);
          } else {
            nextSlide();
          }
        }, errorHandler);
      };
      pingStatus();
    }, errorHandler)
  });
});

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

function ajaxPost(url, data, success, error) {
  var request = new XMLHttpRequest();
  request.open('POST', url, true);
  request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');

  request.onload = function() {
    if (request.status >= 200 && request.status < 400) {
      success(request.responseText, request.status);
    } else {
      error(request.responseText, request.status);
    }
  };

  request.onerror = function() {
    currentSlide().innerHTML = '<div class="error limit-width center">Unrecoverable error has occured.<br /> Please restart the device and try again.</div>';
  };
  request.send(data);
}
