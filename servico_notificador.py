import win32serviceutil
import win32service
import win32event
import time
import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(BASE_DIR)

import notificar


class ServicoNotificador(win32serviceutil.ServiceFramework):
    _svc_name_ = "ServicoNotificadorOS"
    _svc_display_name_ = "Notificador de Chamados HSM"
    _svc_description_ = "Monitora chamados novos no Oracle e envia via ntfy.sh automaticamente"

    def __init__(self, args):
        super().__init__(args)
        self.stop_event = win32event.CreateEvent(None, 0, 0, None)
        self.running = True

    def SvcStop(self):
        self.running = False
        win32event.SetEvent(self.stop_event)

    def SvcDoRun(self):
        while self.running:
            try:
                notificar.main()
            except Exception as e:
                with open(os.path.join(BASE_DIR, "erro.txt"), "a") as f:
                    f.write(str(e) + "\n")

            # Espera 1 minuto, mas checando a cada 1 segundo
            for _ in range(60):
                if not self.running:
                    break
                time.sleep(1)


if __name__ == "__main__":
    win32serviceutil.HandleCommandLine(ServicoNotificador)
