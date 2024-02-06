/*
 * Generated by Bluespec Compiler (build 7d25cde)
 * 
 * On Sun Feb  4 22:37:05 EST 2024
 * 
 */

/* Generation options: */
#ifndef __model_mkXsimTop_h__
#define __model_mkXsimTop_h__

#include "bluesim_types.h"
#include "bs_module.h"
#include "bluesim_primitives.h"
#include "bs_vcd.h"

#include "bs_model.h"
#include "mkXsimTop.h"

/* Class declaration for a model of mkXsimTop */
class MODEL_mkXsimTop : public Model {
 
 /* Top-level module instance */
 private:
  MOD_mkXsimTop *mkXsimTop_instance;
 
 /* Handle to the simulation kernel */
 private:
  tSimStateHdl sim_hdl;
 
 /* Constructor */
 public:
  MODEL_mkXsimTop();
 
 /* Functions required by the kernel */
 public:
  void create_model(tSimStateHdl simHdl, bool master);
  void destroy_model();
  void reset_model(bool asserted);
  void get_version(unsigned int *year,
		   unsigned int *month,
		   char const **annotation,
		   char const **build);
  time_t get_creation_time();
  void * get_instance();
  void dump_state();
  void dump_VCD_defs();
  void dump_VCD(tVCDDumpType dt);
};

/* Function for creating a new model */
extern "C" {
  void * new_MODEL_mkXsimTop();
}

#endif /* ifndef __model_mkXsimTop_h__ */
