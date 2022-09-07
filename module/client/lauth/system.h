#ifndef _LAUTH_SYSTEM_H_
#define _LAUTH_SYSTEM_H_

#include <memory>
#include <string>

namespace mlibrary::lauth {
    class System {
        public:
        virtual std::string getHostname();
        virtual ~System() = default;
    };
}

#endif
