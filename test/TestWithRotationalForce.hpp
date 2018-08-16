#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include <iostream>

// To run in parallel
// #include "PetscSetupAndFinalize.hpp"
// When run in serial
#include "FakePetscSetup.hpp"

#include "AbstractCellBasedTestSuite.hpp"
#include "PetscSetupAndFinalize.hpp"

#include "CellBasedEventHandler.hpp"
#include "CellsGenerator.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "PalssonAdhesionForce.hpp"
#include "OffLatticeSimulation.hpp"
#include "SmartPointers.hpp"
#include "PeriodicNdNodesOnlyMesh.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "RepulsionForce.hpp"
#include "UniformG1GenerationalCellCycleModel.hpp"
#include "FlatBaseMembraneForce.hpp"
#include "PlaneBasedCellKiller.hpp"
#include "CellIdWriter.hpp"
#include "HeightDependentDivisionModifier.hpp"
#include "CellBasedSimulationArchiver.hpp"
#include "PlaneBoundaryCondition.hpp"
#include "ParentAtBaseDivisionRule.hpp"
#include "RotationalDivisionForce.hpp"
#include "FixedDirectionCentreBasedDivisionRule.hpp"
#include "CellHeightAtMPhaseCellModifier.hpp"

#include "../CommonFunctions.hpp"
#include "TestFillTissue.hpp" // Include for accessing required global variables
#include <boost/assign/list_of.hpp>

#include "Debug.hpp"

class TestRotationalForce : public AbstractCellBasedTestSuite
{
private:
    template<unsigned DIM>    
    void RunSimulation(double spring_constant, double spring_power, double adhesion_factor, std::string extension = "") throw(Exception);
public:
    void TestRotationalForce3d() throw(Exception)
    {
        std::vector<double> v_attachment_force = boost::assign::list_of(0.0)(1.0);
        std::vector<double> v_rot_constant = boost::assign::list_of(1.0)(5.0)(10.0)(20.0);

        for (double spring_power = 1.0; spring_power <= 3.0+1e-6; spring_power += 0.5)
        {
            for (std::vector<double>::iterator it_rot_constant = v_rot_constant.begin();
                    it_rot_constant != v_rot_constant.end(); it_rot_constant++)
            {
                for (std::vector<double>::iterator it_attachment_force = v_attachment_force.begin();
                    it_attachment_force != v_attachment_force.end(); it_attachment_force++)
                {
                    RunSimulation<3>(*it_rot_constant,spring_power,*it_attachment_force,"");
                }
            }
        }   
    }
};

template<unsigned DIM>
void TestRotationalForce::RunSimulation(double spring_constant, double spring_power, double adhesion_factor, std::string extension) throw(Exception)
{
    // New setup
    double continued_sim_length = 42.0*24.0;
    double spring_length = std::pow(10.0,-1.0*spring_power);

    // Get appropriate folder paths
    std::string input_file = GetFillTissueOutputFolderAndReseed(spring_power);
    std::stringstream output_file_stream;
    output_file_stream << "RotationalForce/" << _DIM << "d/";
    output_file_stream << "LogSpringLength";
    zeroFill(output_file_stream, (unsigned)(spring_power*10), 2);
    output_file_stream << "e-1_AdhesionMultiplier";
    zeroFill(output_file_stream, (unsigned)(adhesion_factor*10), 2);
    output_file_stream << "e-1_RotationalSpringConstant";
    zeroFill(output_file_stream, (unsigned)(spring_constant*100), 4);
    output_file_stream << "e-2/Seed";
    getSeedAndAppendToFolder(output_file_stream,4);

    // Load the simulation results
    OffLatticeSimulation<DIM>* p_simulator = CellBasedSimulationArchiver<DIM, OffLatticeSimulation<DIM>,DIM >::Load(input_file, gTissueFillSimLength);

    // Set up the reporting
    CellBasedEventHandler::Reset();

    // Change the simulator setup
    p_simulator->SetOutputDirectory(output_file_stream.str());
    p_simulator->SetEndTime(gTissueFillSimLength + continued_sim_length);

    // Change the spring length and set the adhesion strength multiplier
    const std::vector<boost::shared_ptr<AbstractForce<DIM,DIM> > >& rForces = p_simulator->rGetForceCollection();
    for (unsigned i = 0; i < rForces.size(); i++)
    {
        boost::shared_ptr<AbstractUndulatingBaseMembraneForce<DIM> > pBaseForce = boost::dynamic_pointer_cast< AbstractUndulatingBaseMembraneForce<DIM> >(rForces[i]);
        if ( pBaseForce )
        {
            double base_value = pBaseForce->GetAlphaProlifCell();
            double diff_value = pBaseForce->GetAlphaDiffCell();
            pBaseForce->SetAdhesionParameters(base_value*adhesion_factor,diff_value);
        }
    }

    // Add the rotational division force
    MAKE_PTR_ARGS(RotationalDivisionForce<DIM>, p_rot_force, (spring_constant));
    p_simulator->AddForce(p_rot_force);

    // Add the cell modifier
    MAKE_PTR(CellHeightAtMPhaseCellModifier<DIM>, p_modifier);
    p_simulator->AddSimulationModifier(p_modifier);

    // Add the output of the cell modifier cell data
    boost::shared_ptr<CellDataItemWriter<DIM,DIM> > p_cell_data_item_writer(new CellDataItemWriter<DIM,DIM>("HeightAtDivision"));
    p_population.AddCellWriter(p_cell_data_item_writer);

    // Run solver
    p_simulator->Solve();

    // Reportings
    CellBasedEventHandler::Headings();
    CellBasedEventHandler::Report();

    // Delete pointer
    delete p_simulator;
    
}