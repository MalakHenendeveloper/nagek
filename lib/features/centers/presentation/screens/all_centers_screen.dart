import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../domain/entities/center_entity.dart';
import '../cubit/centers_cubit.dart';
import '../cubit/centers_state.dart';
import '../widgets/center_skeletons.dart';
import '../../../../core/routes_manager/routes.dart';



class AllCentersScreen extends StatefulWidget {
  const AllCentersScreen({super.key});

  @override
  State<AllCentersScreen> createState() => _AllCentersScreenState();
}

class _AllCentersScreenState extends State<AllCentersScreen> {
  final ScrollController _scrollController = ScrollController();
  late CentersCubit _centersCubit;

  @override
  void initState() {
    super.initState();
    _centersCubit = getIt<CentersCubit>()..fetchCenters(limit: 10);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _centersCubit.fetchCenters(limit: 10);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _centersCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _centersCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFAF5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCFAF5),
          elevation: 0,
          title: Text(
            'جميع مراكز الصيانة',
            style: GoogleFonts.cairo(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<CentersCubit, CentersState>(
            builder: (context, state) {
              if (state is CentersInitial || (state is CentersLoading && _centersCubit.state is! CentersLoaded)) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return const CenterCardSkeleton();
                  },
                );
              } else if (state is CentersError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                );
              } else if (state is CentersLoaded) {
                final centers = state.centers;
                if (centers.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد مراكز صيانة متاحة',
                      style: GoogleFonts.cairo(fontSize: 16),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFFFFC107),
                  onRefresh: () async {
                    await _centersCubit.fetchCenters(limit: 10, isRefresh: true);
                  },
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: state.hasReachedMax ? centers.length : centers.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= centers.length) {
                        return const CenterCardSkeleton();
                      }

                      final center = centers[index];
                      return _buildCenterCard(center);
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCenterCard(CenterEntity center) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.centerDetailsRoute,
          arguments: center.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                image: center.logo.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(center.logo),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: center.logo.isEmpty
                  ? const Center(
                      child: Icon(Icons.handyman_outlined, color: Colors.white54, size: 40),
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.name,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      center.rating.toString(),
                      style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.grey, size: 12),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${center.city} • ${center.address}',
                        style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
