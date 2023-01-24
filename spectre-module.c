#include "emacs-module.h"
#include <spectre-algorithm.h>
#include <spectre-types.h>
#include <string.h>
#include <stdio.h>

/* Declare mandatory GPL symbol.  */
int plugin_is_GPL_compatible;

/* New emacs lisp function. All function exposed to Emacs must have this prototype. */
static emacs_value Fpassword (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void *data)
{
  ptrdiff_t buf_size = 128;
  char name_buf[buf_size];
  env->copy_string_contents(env, args[0], name_buf, &buf_size);
  //return env->make_string (env, name_buf, strlen(name_buf));
  buf_size = 128;
  char secret_buf[buf_size];
  env->copy_string_contents(env, args[1], secret_buf, &buf_size);
  //return env->make_string (env, secret_buf, strlen(secret_buf));
  buf_size = 128;
  char site_buf[buf_size];
  env->copy_string_contents(env, args[2], site_buf, &buf_size);
  //return env->make_string (env, site_buf, strlen(site_buf));

  if (strlen(site_buf) == 0 ||
      strlen(secret_buf) == 0 ||
      strlen(name_buf) == 0)
    return env->make_integer(env, 0);

  const SpectreUserKey* user_key = spectre_user_key((const char*)name_buf, (const char*)secret_buf, SpectreAlgorithmV3);
  const char* password = spectre_site_result(user_key, (const char*)site_buf, SpectreResultTemplateLong, "", 1, SpectreKeyPurposeAuthentication, "");

  return env->make_string (env, password, strlen(password));
}

/* Bind NAME to FUN.  */
static void bind_function (emacs_env *env, const char *name, emacs_value Sfun)
{
  /* Set the function cell of the symbol named NAME to SFUN using
     the 'fset' function.  */

  /* Convert the strings to symbols by interning them */
  emacs_value Qfset = env->intern (env, "fset");
  emacs_value Qsym = env->intern (env, name);

  /* Prepare the arguments array */
  emacs_value args[] = { Qsym, Sfun };

  /* Make the call (2 == nb of arguments) */
  env->funcall (env, Qfset, 2, args);
}

/* Provide FEATURE to Emacs.  */
static void provide (emacs_env *env, const char *feature)
{
  /* call 'provide' with FEATURE converted to a symbol */

  emacs_value Qfeat = env->intern (env, feature); emacs_value Qprovide = env->intern (env, "provide");
  emacs_value args[] = { Qfeat };

  env->funcall (env, Qprovide, 1, args);
}

int emacs_module_init (struct emacs_runtime *ert)
{
  emacs_env *env = ert->get_environment (ert);

  /* create a lambda (returns an emacs_value) */
  emacs_value fun = env->make_function (env,
              3,            /* min. number of arguments */
              3,            /* max. number of arguments */
              Fpassword,  /* actual function pointer */
              "doc",        /* docstring */
              NULL          /* user pointer of your choice (data param in Fmymod_test) */
  );

  bind_function (env, "spectre-make-password", fun);
  provide (env, "spectre-module");

  /* loaded successfully */
  return 0;
}
