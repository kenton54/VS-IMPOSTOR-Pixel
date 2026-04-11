#include <iostream>
#include <string>
#include <locale>

std::string Linux_GetUserLanguage()
{
  std::locale loc("");
  return loc.name();
}
