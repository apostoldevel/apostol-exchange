/*++

Programm name:

  Apostol

Module Name:

  Apostol.hpp

Notices:

  Apostol Web Service

Author:

  Copyright (c) Prepodobny Alen

  mailto: alienufo@inbox.ru
  mailto: ufocomp@gmail.com

--*/

#ifndef APOSTOL_APOSTOL_HPP
#define APOSTOL_APOSTOL_HPP

#include "../../version.h"
//----------------------------------------------------------------------------------------------------------------------

#define APP_VERSION      AUTO_VERSION
#define APP_VER          APP_NAME "/" APP_VERSION
//----------------------------------------------------------------------------------------------------------------------

#include "Core.hpp"
#include "../modules/Modules.hpp"
//----------------------------------------------------------------------------------------------------------------------

extern "C++" {

namespace Apostol {

    namespace Exchange {

        class CExBot: public CApplication {
        protected:

            void ParseCmdLine() override;
            void ShowVersionInfo() override;

        public:

            CExBot(int argc, char *const *argv): CApplication(argc, argv) {
                CreateModule(this);
            };

            ~CExBot() override = default;

            static class CExBot *Create(int argc, char *const *argv) {
                return new CExBot(argc, argv);
            };

            inline void Destroy() override { delete this; };

            void Run() override;

        };
    }
}

using namespace Apostol::Exchange;
}

#endif //APOSTOL_APOSTOL_HPP

