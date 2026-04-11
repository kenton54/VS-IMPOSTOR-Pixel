#include <iostream>
#include <cstdlib>
#include <string>
#include <fstream>

std::string Linux_GetUserLanguage()
{
  const char *lang = std::getenv("LANG");

  if (lang != nullptr)
  {
    return lang;
  }

  return "en-US";
}
