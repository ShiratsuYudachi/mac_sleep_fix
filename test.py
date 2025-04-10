from gi.repository import Gio

def on_prepare_for_sleep(conn, sender, obj, interface, signal, parameters, data):
    if not parameters:  # 参数为False表示刚刚唤醒
        print("System just woke up!")
    else:  # 参数为True表示即将进入睡眠
        print("System is about to sleep.")

system_bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
system_bus.signal_subscribe(
    'org.freedesktop.login1',
    'org.freedesktop.login1.Manager',
    'PrepareForSleep',
    '/org/freedesktop/login1',
    None,
    Gio.DBusSignalFlags.NONE,
    on_prepare_for_sleep,
    None
)
