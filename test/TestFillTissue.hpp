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
#include "SinusoidalBaseMembraneForce.hpp"
#include "PlaneBasedCellKiller.hpp"
#include "CellIdWriter.hpp"
#include "HeightDependentDivisionModifier.hpp"
#include "CellBasedSimulationArchiver.hpp"
#include "PlaneBoundaryCondition.hpp"
#include "NodeVelocityWriter.hpp"
#include "CellMutationStatesWriter.hpp"
#include "CellDeathWriter.hpp"
#include "CellProliferativeTypesCountWriter.hpp"
#include "LiRepulsionForce.hpp"
#include "CellCountThresholderSimulationModifier.hpp"
#include "VerticallyFixedStemCellBoundaryCondition.hpp"

#include "FixedDirectionCentreBasedDivisionRule.hpp"

#include "../CommonFunctions.hpp"

// Global variables that are needed for subsequent simulations
const unsigned _DIM = 3;
const double gTissueFillSimLength = 21.0*24.0;

const std::string gTissueFill2dOutputFile = "FilledTissue/2dExp/";
const std::string gTissueFill3dOutputFile = "FilledTissue/3dExp/";

std::string GetFillTissueOutputFolderAndReseed(double log_spring_length)
{
    assert(std::abs(log_spring_length) >= 1.0);
    std::stringstream output_file_stream;
    if (_DIM==3)
    {
        output_file_stream << gTissueFill3dOutputFile;
    }
    else
    {
        output_file_stream << gTissueFill2dOutputFile;
    }
    output_file_stream << "LogSpringLength" << (unsigned)std::abs(log_spring_length*10.0) << "e-1/Seed";
    unsigned seed = getSeedAndAppendToFolder(output_file_stream,4);
    RandomNumberGenerator::Instance()->Reseed(seed);
    return(output_file_stream.str());
}

class TestInitialTransient : public AbstractCellBasedTestSuite
{
    void RunFill(double log_spring_length) throw(Exception);
    
public:
    void TestFillTissueWithExpRepulsion() throw(Exception)
    {
        // Loop over each spring length
        for ( double log_sl = 1.0; log_sl < 3.1; log_sl += 0.5)
        {
            // Make a pointer to the force
            RunFill(-1.0*log_sl);
        }
    }
};

void TestInitialTransient::RunFill(double log_spring_length) throw(Exception)
{
    // Assign a boolean for convenience
    bool dim3 = (_DIM==3);

    // Get the seed and assign folder
    std::string output_folder = GetFillTissueOutputFolderAndReseed(log_spring_length);

    // Set up the reporting
    CellBasedEventHandler::Reset();

    // The parameters for the sim   
    unsigned base_width_x = 10;
    unsigned base_width_y = dim3 ? 10 : 1;
    double height = 10.0;
    unsigned n_stem = base_width_x*base_width_y;
    unsigned output_freq = 24*120;
    double spring_length = std::pow(10.0,log_spring_length);

    // Set up the nodes in standard setup
    std::vector<Node<_DIM>*> nodes(n_stem);
    for ( unsigned i=0; i < base_width_x; i++ )
    {
        for (unsigned j = 0; j < base_width_y; j++)
        {
            unsigned id = j*base_width_x + i;
            double x = i;
            double y = j;
            double z = 0.0;
            nodes[id] = new Node<_DIM>( id,false, x,y,z);
        }
    }

    // Construct the mesh
    std::vector<double> periodic_widths(_DIM-1);
    periodic_widths[0] = base_width_x;
    if ( dim3 )
    {
        periodic_widths[1] = base_width_y;
    }
    PeriodicNdNodesOnlyMesh<_DIM> mesh(periodic_widths,true,dim3,false);
    mesh.ConstructNodesWithoutMesh(nodes,2.0);

    // Create the cells
    std::vector<CellPtr> cells;
    CellsGenerator<UniformG1GenerationalCellCycleModel, _DIM> cells_generator;
    MAKE_PTR(StemCellProliferativeType, p_stem_type);
    cells_generator.GenerateBasicRandom(cells, mesh.GetNumNodes(), p_stem_type);
    for ( std::vector<CellPtr>::iterator cell_it = cells.begin(); cell_it != cells.end(); cell_it++ )
    {
        UniformG1GenerationalCellCycleModel* p_model = dynamic_cast<UniformG1GenerationalCellCycleModel*>((*cell_it)->GetCellCycleModel());
        p_model->SetMaxTransitGenerations(0);
        p_model->SetStemCellG1Duration(3);
    }

    // Create cell population
    NodeBasedCellPopulation<_DIM> cell_population(mesh, cells);
    cell_population.SetAbsoluteMovementThreshold(1.5);

    // Set up simulator
    OffLatticeSimulation<_DIM> simulator(cell_population);
    simulator.SetOutputDirectory(output_folder);
    simulator.SetSamplingTimestepMultiple(output_freq);
    simulator.SetEndTime(gTissueFillSimLength);

    // Add any extra output
    cell_population.AddCellWriter<CellIdWriter>();
    cell_population.AddCellWriter<CellMutationStatesWriter>();
    cell_population.AddPopulationWriter<NodeVelocityWriter>();
    cell_population.AddCellPopulationCountWriter<CellDeathWriter>();
    cell_population.AddCellPopulationCountWriter<CellProliferativeTypesCountWriter>();

    // Add the adhesive cell-cell force and the repulsion force
    MAKE_PTR( PalssonAdhesionForce<_DIM>, p_adhesion_force );
    MAKE_PTR(RepulsionForce<_DIM>, p_rep_force);
    // Change the spring lengths
    p_adhesion_force->SetMeinekeDivisionRestingSpringLength(spring_length);
    p_rep_force->SetMeinekeDivisionRestingSpringLength(spring_length);
    simulator.AddForce(p_adhesion_force);
    simulator.AddForce(p_rep_force);

    // Add the sloughing at the top
    c_vector<double,_DIM> pt = zero_vector<double>(_DIM);
    c_vector<double,_DIM> nml = zero_vector<double>(_DIM);
    pt[_DIM-1] = height;
    nml[_DIM-1] = 1.0;
    MAKE_PTR_ARGS(PlaneBasedCellKiller<_DIM>,p_killer,(&cell_population,pt,nml));
    simulator.AddCellKiller(p_killer);

    // Add the bottom boundaries
    MAKE_PTR(FlatBaseMembraneForce<_DIM>, p_base);
    simulator.AddForce(p_base);
    MAKE_PTR_ARGS(VerticallyFixedStemCellBoundaryCondition<_DIM>, p_sc_bc, (&cell_population));
    simulator.AddCellPopulationBoundaryCondition(p_sc_bc);

    // Add the simulation modifier to check that the output of the simulation is not too large
    MAKE_PTR_ARGS(CellCountThresholderSimulationModifier<_DIM>, p_count_modifier, (base_width_x*base_width_y*10*2));
    simulator.AddSimulationModifier(p_count_modifier);

    // Add in the division direction
    c_vector<double,_DIM> div_vec = zero_vector<double>(_DIM);
    div_vec[_DIM-1] = spring_length;
    MAKE_PTR_ARGS(FixedDirectionCentreBasedDivisionRule<_DIM>,p_div_rule,(div_vec));
    cell_population.SetCentreBasedDivisionRule(p_div_rule);

    // Run solver
    simulator.Solve();

    // Remove the population boundary condition
    simulator.RemoveAllCellPopulationBoundaryConditions();

    // Save the results
    CellBasedSimulationArchiver<_DIM,OffLatticeSimulation<_DIM>, _DIM>::Save(&simulator);

    // Reporting
    CellBasedEventHandler::Headings();
    CellBasedEventHandler::Report();

    // Reset the singletons
    SimulationTime::Destroy();
    SimulationTime::Instance()->SetStartTime(0.0);
    RandomNumberGenerator::Destroy();
}
