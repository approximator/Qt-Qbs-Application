#include "tools_plugin.h"
#include "fpsitem.h"

#include <qqml.h>

void ToolsPlugin::registerTypes(const char *uri)
{
    // @uri Simple.Tools
    qmlRegisterType<FpsItem>(uri, 1, 0, "FpsItem");
}

