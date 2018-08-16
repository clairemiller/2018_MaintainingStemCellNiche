#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include <iostream>

// To run in parallel
#include "PetscSetupAndFinalize.hpp"
// When run in serial
// #include "FakePetscSetup.hpp"

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
#include "FixedDirectionCentreBasedDivisionRule.hpp"
#include "FixedCellBoundaryCondition.hpp"

#include "../CommonFunctions.hpp"
#include "TestFillTissue.hpp" // Include for accessing required global variables
#include "TestLiPaperResults.hpp"

#include "Debug.hpp"

class TestFromFullTissue : public AbstractCellBasedTestSuite
{
public:
    void Test3dPinnedComparisonSimulationExponentialRepulsion() throw(Exception)
    {
        double continued_sim_length = 42.0*24.0;
        double log_spring_length = 3;
        double spring_length = std::pow(10.0,-1.0*log_spring_length);

        // Get the output/input folder names
        std::stringstream output_file_stream;
        output_file_stream << "PinnedComparison/ExponentialRepulsion/SpringLength";
        output_file_stream << log_spring_length*10;
        output_file_stream << "e-1/3d/Seed";

        getSeedAndAppendToFolder(output_file_stream,4);
        std::string input_file = GetFillTissueOutputFolderAndReseed(log_spring_length);

        // Load the simulation results
        OffLatticeSimulation<3>* p_simulator = CellBasedSimulationArchiver<3, OffLatticeSimulation<3>,3 >::Load(input_file, gTissueFillSimLength);

        // Set up the reporting
        CellBasedEventHandler::Reset();

        // Change the simulator setup
        p_simulator->SetOutputDirectory(output_file_stream.str());
        p_simulator->SetEndTime(gTissueFillSimLength + continued_sim_length);

        // Add the stem cell restriction
        MAKE_PTR_ARGS(VerticallyFixedStemCellBoundaryCondition<3>, p_sc_bc, (&(p_simulator->rGetCellPopulation())));
        p_simulator->AddCellPopulationBoundaryCondition(p_sc_bc);

        // Run solver
        p_simulator->Solve();

        // Reporting
        CellBasedEventHandler::Headings();
        CellBasedEventHandler::Report();

        // Delete pointer
        delete p_simulator;
        
    }

    void DNRTest3dPinnedComparisonSimulationLiRepulsion() throw(Exception)
    {
        // New setup
        double continued_sim_length = 42.0*24.0;
        double spring_length = 0.1;
        double spring_parameter = 1.0;
        std::string output_file = "PinnedComparison/LiRepulsion/3d/Seed";

        // Get the folders
        std::stringstream output_file_stream;
        output_file_stream << output_file;
        getSeedAndAppendToFolder(output_file_stream,4);
        std::string input_folder = GetFillOutputFolder();

        // Load the simulation results
        OffLatticeSimulation<3>* p_simulator = CellBasedSimulationArchiver<3, OffLatticeSimulation<3>,3 >::Load(input_folder, gTissueFillSimLengthLi);

        // Set up the reporting
        CellBasedEventHandler::Reset();

        // Change the simulator setup
        p_simulator->SetOutputDirectory(output_file_stream.str());
        p_simulator->SetEndTime(gTissueFillSimLengthLi + continued_sim_length);

        // Add the stem cell pinning
        NodeBasedCellPopulation<3>& r_population = dynamic_cast<NodeBasedCellPopulation<3>& >(p_simulator->rGetCellPopulation());
        MAKE_PTR_ARGS(FixedCellBoundaryCondition<3>,p_bc,(&r_population));
        p_simulator->AddCellPopulationBoundaryCondition(p_bc);

        // Reset all the base boundary nodes to z=0
        for( NodeBasedCellPopulation<3>::Iterator cell_iter = r_population.Begin();
        cell_iter != r_population.End(); ++cell_iter )
        {
            if (cell_iter->GetCellProliferativeType()->template IsType<StemCellProliferativeType>())
            {
                r_population.GetNodeCorrespondingToCell(*cell_iter)->rGetModifiableLocation()[2] = 0.0;            
            }
        }

        // Run solver
        p_simulator->Solve();

        // Reporting
        CellBasedEventHandler::Headings();
        CellBasedEventHandler::Report();

        // Delete pointer
        delete p_simulator;
        
    }
};