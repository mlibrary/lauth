#include "lauth/system.h"

#include <unistd.h>

namespace mlibrary::lauth {
    std::string System::getHostname() {
        char servername[129];
        gethostname(servername, 128);
        servername[128] = '\0';
        return std::string(servername);
    }
}

