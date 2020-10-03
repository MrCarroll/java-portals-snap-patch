CC=gcc
CFLAGS=-fPIC -shared 
TARGET=g_app_info_launch_default_for_uri

all: $(TARGET)

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) -o $(TARGET).so $(TARGET).c
	
clean:
	$(RM) $(TARGET).so

install: $(TARGET)
	install -D -m644 $(TARGET).so "$(DESTDIR)"/usr/lib/$(TARGET).so
